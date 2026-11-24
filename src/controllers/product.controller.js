const db = require('../config/db');
const h = require('../utils/asyncHandler');
const { httpError } = require('../utils/httpError');
const { saveTiers } = require('../utils/price');

// Tier yang dikirim hanya milik role si peminta (admin melihat tier pelanggan).
exports.list = h(async (req, res) => {
  const [rows] = await db.query('SELECT * FROM products ORDER BY id');
  const [tiers] = await db.query(
    'SELECT product_id, min_kg, harga_per_kg FROM price_tiers WHERE untuk_role = ? ORDER BY min_kg',
    [req.user.role === 'reseller' ? 'reseller' : 'pelanggan']
  );
  res.json(rows.map((p) => ({ ...p, tiers: tiers.filter((t) => t.product_id === p.id) })));
});

exports.create = h(async (req, res) => {
  const { nama, kategori, harga_dasar, stok_kg, deskripsi = '' } = req.body;
  const id = await db.tx(async (c) => {
    const [r] = await c.query(
      'INSERT INTO products (nama, kategori, deskripsi, harga_dasar, stok_kg, foto) VALUES (?, ?, ?, ?, ?, ?)',
      [nama, kategori, deskripsi, harga_dasar, stok_kg, req.file ? req.file.filename : null]
    );
    await saveTiers(c, r.insertId, Number(harga_dasar));
    return r.insertId;
  });
  res.status(201).json({ id });
});

exports.update = h(async (req, res) => {
  const { nama, kategori, harga_dasar, stok_kg, deskripsi = '' } = req.body;
  await db.tx(async (c) => {
    const [r] = await c.query(
      'UPDATE products SET nama = ?, kategori = ?, deskripsi = ?, harga_dasar = ?, stok_kg = ?, foto = COALESCE(?, foto) WHERE id = ?',
      [nama, kategori, deskripsi, harga_dasar, stok_kg, req.file ? req.file.filename : null, req.params.id]
    );
    if (!r.affectedRows) throw httpError(404, 'Produk tidak ditemukan.');
    await saveTiers(c, Number(req.params.id), Number(harga_dasar));
  });
  res.json({ message: 'Produk diperbarui.' });
});

exports.remove = h(async (req, res) => {
  const [r] = await db.query('DELETE FROM products WHERE id = ?', [req.params.id]);
  if (!r.affectedRows) throw httpError(404, 'Produk tidak ditemukan.');
  res.json({ message: 'Produk dihapus.' });
});
