module.exports = (err, req, res, next) => {
  if (err.code === 'LIMIT_FILE_SIZE') return res.status(400).json({ message: 'Ukuran file maksimal 2 MB.' });
  if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ message: 'Data sudah terdaftar.' });
  if (err.code === 'ER_ROW_IS_REFERENCED_2')
    return res.status(409).json({ message: 'Data masih dipakai, tidak bisa dihapus.' });
  const status = err.status || 500;
  if (status === 500) console.error(err);
  res.status(status).json({ message: status === 500 ? 'Terjadi kesalahan pada server.' : err.message });
};
