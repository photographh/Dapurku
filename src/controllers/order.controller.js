const db = require('../config/db');
const h = require('../utils/asyncHandler');
const { httpError } = require('../utils/httpError');
const { unitPrice } = require('../utils/price');

// Alur status yang diizinkan. "menunggu_pembayaran" dari menunggu_konfirmasi = bukti ditolak.
const NEXT = {
  menunggu_konfirmasi: ['dibayar', 'menunggu_pembayaran'],
  dibayar: ['diproses'],
  diproses: ['dikirim'],
  dikirim: ['selesai'],
};

// Harga SELALU dihitung di sini, bukan dipercaya dari aplikasi.
exports.create = h(async (req, res) => {
  const { nama_penerima, no_hp, alamat, items } = req.body;
  const out = await db.tx(async (c) => {
    let total = 0;
    const lines = [];
    for (const it of items) {
      const [[p]] = await c.query('SELECT id, nama, harga_dasar, stok_kg FROM products WHERE id = ?', [it.product_id]);
      if (!p) throw httpError(404, 'Produk tidak ditemukan.');
      const qty = Number(it.jumlah_kg);
      if (qty > p.stok_kg) throw httpError(400, `Stok ${p.nama} hanya tinggal ${p.stok_kg} kg.`);
      const [tiers] = await c.query(
        'SELECT min_kg, harga_per_kg FROM price_tiers WHERE product_id = ? AND untuk_role = ? ORDER BY min_kg',
        [p.id, req.user.role]
      );
      const harga = unitPrice(tiers, qty) ?? p.harga_dasar;
      total += harga * qty;
      lines.push([p.id, qty, harga]);
    }
    total = Math.round(total);
    const [o] = await c.query(
      'INSERT INTO orders (user_id, nama_penerima, no_hp, alamat, total) VALUES (?, ?, ?, ?, ?)',
      [req.user.id, nama_penerima, no_hp, alamat, total]
    );
    await c.query('INSERT INTO order_items (order_id, product_id, jumlah_kg, harga_per_kg) VALUES ?', [
      lines.map((l) => [o.insertId, ...l]),
    ]);
    return { id: o.insertId, total };
  });
  res.status(201).json(out);
});

exports.list = h(async (req, res) => {
  const admin = req.user.role === 'admin';
  const [orders] = await db.query(
    `SELECT o.*, u.nama AS user_nama FROM orders o JOIN users u ON u.id = o.user_id
     ${admin ? '' : 'WHERE o.user_id = ?'} ORDER BY o.id DESC`,
    admin ? [] : [req.user.id]
  );
  if (!orders.length) return res.json([]);
  const [items] = await db.query(
    `SELECT oi.order_id, oi.jumlah_kg, oi.harga_per_kg, p.nama
     FROM order_items oi JOIN products p ON p.id = oi.product_id WHERE oi.order_id IN (?)`,
    [orders.map((o) => o.id)]
  );
  res.json(orders.map((o) => ({ ...o, items: items.filter((i) => i.order_id === o.id) })));
});

exports.payment = h(async (req, res) => {
  if (!req.file) throw httpError(400, 'File bukti transfer wajib diunggah.');
  const [[o]] = await db.query('SELECT id, status FROM orders WHERE id = ? AND user_id = ?', [req.params.id, req.user.id]);
  if (!o) throw httpError(404, 'Pesanan tidak ditemukan.');
  if (o.status !== 'menunggu_pembayaran') throw httpError(400, 'Pesanan ini tidak sedang menunggu pembayaran.');
  await db.query("UPDATE orders SET bukti_transfer = ?, status = 'menunggu_konfirmasi' WHERE id = ?", [
    req.file.filename,
    o.id,
  ]);
  res.json({ message: 'Bukti transfer terkirim.' });
});

exports.setStatus = h(async (req, res) => {
  const { status } = req.body;
  await db.tx(async (c) => {
    const [[o]] = await c.query('SELECT id, status FROM orders WHERE id = ? FOR UPDATE', [req.params.id]);
    if (!o) throw httpError(404, 'Pesanan tidak ditemukan.');
    if (!(NEXT[o.status] || []).includes(status))
      throw httpError(400, `Status tidak bisa diubah dari ${o.status} ke ${status}.`);
    // Stok baru berkurang saat pembayaran dikonfirmasi.
    if (status === 'dibayar') {
      const [items] = await c.query('SELECT product_id, jumlah_kg FROM order_items WHERE order_id = ?', [o.id]);
      for (const i of items) {
        const [r] = await c.query('UPDATE products SET stok_kg = stok_kg - ? WHERE id = ? AND stok_kg >= ?', [
          i.jumlah_kg, i.product_id, i.jumlah_kg,
        ]);
        if (!r.affectedRows) throw httpError(400, 'Stok tidak cukup untuk menyetujui pesanan ini.');
      }
    }
    await c.query(
      `UPDATE orders SET status = ?, bukti_transfer = IF(? = 'menunggu_pembayaran', NULL, bukti_transfer) WHERE id = ?`,
      [status, status, o.id]
    );
  });
  res.json({ message: 'Status diperbarui.' });
});

exports.summary = h(async (req, res) => {
  const [[a]] = await db.query(
    `SELECT COUNT(*) AS total,
            COALESCE(SUM(status = 'menunggu_konfirmasi'), 0) AS perlu_dicek,
            COALESCE(SUM(CASE WHEN status NOT IN ('menunggu_pembayaran','menunggu_konfirmasi') THEN total END), 0) AS omzet
     FROM orders`
  );
  const [[s]] = await db.query('SELECT COUNT(*) AS stok_tipis FROM products WHERE stok_kg <= 25');
  res.json({
    total: Number(a.total),
    perlu_dicek: Number(a.perlu_dicek),
    omzet: Number(a.omzet),
    stok_tipis: Number(s.stok_tipis),
  });
});
