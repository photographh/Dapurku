const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/db');
const h = require('../utils/asyncHandler');
const { httpError } = require('../utils/httpError');

const sign = (u) => jwt.sign({ id: u.id, role: u.role }, process.env.JWT_SECRET, { expiresIn: '7d' });
const clean = ({ password, ...u }) => u;

// Register selalu membuat akun role "pelanggan". Role lain lewat seed/admin.
exports.register = h(async (req, res) => {
  const { nama, email, password } = req.body;
  const hash = await bcrypt.hash(password, 10);
  const [r] = await db.query(
    "INSERT INTO users (nama, email, password, role) VALUES (?, ?, ?, 'pelanggan')",
    [nama, email, hash]
  );
  res.status(201).json({ message: 'Registrasi berhasil.', id: r.insertId });
});

exports.login = h(async (req, res) => {
  const { email, password } = req.body;
  const [[u]] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
  if (!u || !(await bcrypt.compare(password, u.password))) throw httpError(401, 'Email atau password salah.');
  res.json({ token: sign(u), user: clean(u) });
});
