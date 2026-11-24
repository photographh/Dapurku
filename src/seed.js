// Jalankan: npm run seed  (setelah schema.sql dijalankan)
require('dotenv').config();
const bcrypt = require('bcryptjs');
const db = require('./config/db');
const { saveTiers } = require('./utils/price');

const USERS = [
  ['Admin Warung', 'admin@warung.com', 'admin123', 'admin'],
  ['Budi Pelanggan', 'pelanggan@warung.com', 'pelanggan123', 'pelanggan'],
  ['Sari Reseller', 'reseller@warung.com', 'reseller123', 'reseller'],
];

const PRODUCTS = [
  ['Bawang merah', 'bawang', 'Segar pilihan, siap masak', 32000, 120],
  ['Bawang putih', 'bawang', 'Wangi, kering, tahan lama', 38000, 80],
  ['Bawang goreng', 'bawang', 'Renyah, tanpa pengawet', 95000, 25],
  ['Bawang bombay', 'bawang', 'Besar, renyah, pas buat tumisan', 28000, 60],
  ['Cabai rawit', 'bumbu', 'Pedas nampol, baru dipetik', 60000, 30],
  ['Jahe merah', 'bumbu', 'Aroma tajam, cocok buat wedang', 45000, 40],
  ['Kunyit', 'bumbu', 'Warna pekat, bumbu dapur wajib', 25000, 50],
  ['Paket hemat', 'paket', 'Merah, putih, dan goreng', 150000, 15],
];

(async () => {
  for (const [nama, email, pw, role] of USERS) {
    await db.query(
      'INSERT INTO users (nama, email, password, role) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE password = VALUES(password), role = VALUES(role)',
      [nama, email, await bcrypt.hash(pw, 10), role]
    );
  }
  const [[{ n }]] = await db.query('SELECT COUNT(*) AS n FROM products');
  if (n === 0) {
    for (const [nama, kategori, deskripsi, harga, stok] of PRODUCTS) {
      await db.tx(async (c) => {
        const [r] = await c.query(
          'INSERT INTO products (nama, kategori, deskripsi, harga_dasar, stok_kg) VALUES (?, ?, ?, ?, ?)',
          [nama, kategori, deskripsi, harga, stok]
        );
        await saveTiers(c, r.insertId, harga);
      });
    }
  }
  console.log('Seed selesai. Akun uji: admin@warung.com / admin123, pelanggan@warung.com / pelanggan123, reseller@warung.com / reseller123');
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
