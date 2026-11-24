const bcrypt = require('bcryptjs');
const db = require('../config/db');
const h = require('../utils/asyncHandler');
const { httpError } = require('../utils/httpError');

// id selalu diambil dari token, bukan dari URL.
exports.get = h(async (req, res) => {
  const [[u]] = await db.query('SELECT id, nama, email, role, no_hp, alamat, foto FROM users WHERE id = ?', [req.user.id]);
  if (!u) throw httpError(404, 'Akun tidak ditemukan.');
  res.json(u);
});

exports.update = h(async (req, res) => {
  const { nama, no_hp = null, alamat = null } = req.body;
  await db.query('UPDATE users SET nama = ?, no_hp = ?, alamat = ? WHERE id = ?', [nama, no_hp, alamat, req.user.id]);
  res.json({ message: 'Profil diperbarui.' });
});

exports.photo = h(async (req, res) => {
  if (!req.file) throw httpError(400, 'Foto wajib diunggah.');
  await db.query('UPDATE users SET foto = ? WHERE id = ?', [req.file.filename, req.user.id]);
  res.json({ foto: req.file.filename });
});

exports.password = h(async (req, res) => {
  const { password_lama, password_baru } = req.body;
  const [[u]] = await db.query('SELECT password FROM users WHERE id = ?', [req.user.id]);
  if (!(await bcrypt.compare(password_lama, u.password))) throw httpError(400, 'Password lama salah.');
  await db.query('UPDATE users SET password = ? WHERE id = ?', [await bcrypt.hash(password_baru, 10), req.user.id]);
  res.json({ message: 'Password diganti.' });
});
