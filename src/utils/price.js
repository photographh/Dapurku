// Faktor diskon grosir: [minimal kg, pengali harga dasar]
const RULES = {
  pelanggan: [[1, 1], [10, 0.95], [50, 0.9]],
  reseller: [[1, 0.95], [10, 0.9], [50, 0.85]],
};
const round = (n) => Math.round(n / 100) * 100;

const tiersFor = (harga) =>
  Object.entries(RULES).flatMap(([role, rs]) =>
    rs.map(([min, f]) => ({ min_kg: min, harga_per_kg: round(harga * f), untuk_role: role }))
  );

// tiers harus terurut naik berdasarkan min_kg. Ambil tier terbesar yang masih terpenuhi.
exports.unitPrice = (tiers, qty) => {
  let h = null;
  for (const t of tiers) if (qty >= t.min_kg) h = t.harga_per_kg;
  return h;
};

// Buat ulang semua tier sebuah produk dari harga dasarnya.
exports.saveTiers = async (conn, productId, harga) => {
  await conn.query('DELETE FROM price_tiers WHERE product_id = ?', [productId]);
  const rows = tiersFor(harga).map((t) => [productId, t.min_kg, t.harga_per_kg, t.untuk_role]);
  await conn.query('INSERT INTO price_tiers (product_id, min_kg, harga_per_kg, untuk_role) VALUES ?', [rows]);
};
