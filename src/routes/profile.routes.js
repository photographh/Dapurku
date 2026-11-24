const r = require('express').Router();
const { body } = require('express-validator');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');
const v = require('../middleware/validate');
const c = require('../controllers/profile.controller');

r.use(auth);
r.get('/', c.get);
r.put('/', [
  body('nama').trim().isLength({ min: 3 }).withMessage('Nama minimal 3 karakter.'),
  body('no_hp').optional({ values: 'falsy' }).matches(/^(08|\+628)\d{8,12}$/).withMessage('Nomor HP tidak valid.'),
  body('alamat').optional({ values: 'falsy' }).isLength({ min: 10 }).withMessage('Alamat minimal 10 karakter.'),
], v, c.update);
r.post('/photo', upload.single('foto'), c.photo);
r.put('/password', [
  body('password_lama').notEmpty().withMessage('Password lama wajib diisi.'),
  body('password_baru').isLength({ min: 6 }).withMessage('Password baru minimal 6 karakter.'),
], v, c.password);

module.exports = r;
