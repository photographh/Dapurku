const r = require('express').Router();
const { body } = require('express-validator');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const upload = require('../middleware/upload');
const v = require('../middleware/validate');
const c = require('../controllers/product.controller');

const rules = [
  body('nama').trim().isLength({ min: 3 }).withMessage('Nama produk minimal 3 karakter.'),
  body('kategori').isIn(['bawang', 'bumbu', 'paket']).withMessage('Kategori tidak valid.'),
  body('harga_dasar').isInt({ min: 1 }).withMessage('Harga dasar harus angka positif.'),
  body('stok_kg').isFloat({ min: 0 }).withMessage('Stok tidak boleh negatif.'),
];

r.use(auth);
r.get('/', c.list);
r.post('/', role('admin'), upload.single('foto'), rules, v, c.create);
r.put('/:id', role('admin'), upload.single('foto'), rules, v, c.update);
r.delete('/:id', role('admin'), c.remove);

module.exports = r;
