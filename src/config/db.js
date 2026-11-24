const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  decimalNumbers: true, // DECIMAL dibaca sebagai angka, bukan string
  waitForConnections: true,
  connectionLimit: 10,
});

// Jalankan beberapa query dalam satu transaksi. Gagal = rollback otomatis.
pool.tx = async (fn) => {
  const c = await pool.getConnection();
  try {
    await c.beginTransaction();
    const result = await fn(c);
    await c.commit();
    return result;
  } catch (e) {
    await c.rollback();
    throw e;
  } finally {
    c.release();
  }
};

module.exports = pool;
