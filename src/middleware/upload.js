const multer = require('multer');
const path = require('path');
const fs = require('fs');

fs.mkdirSync('uploads', { recursive: true });

module.exports = multer({
  storage: multer.diskStorage({
    destination: 'uploads',
    filename: (req, f, cb) =>
      cb(null, Date.now() + '-' + Math.round(Math.random() * 1e6) + path.extname(f.originalname).toLowerCase()),
  }),
  limits: { fileSize: 2 * 1024 * 1024 }, // 2 MB
  fileFilter: (req, f, cb) =>
    /\.(jpe?g|png|webp)$/i.test(f.originalname)
      ? cb(null, true)
      : cb(Object.assign(new Error('File harus berupa gambar (jpg, png, webp).'), { status: 400 })),
});
