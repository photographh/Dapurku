const r = require('express').Router();
const { body } = require('express-validator');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const upload = require('../middleware/upload');
const v = require('../middleware/validate');
const c = require('../controllers/order.controller');

const createRules = [
  body('nama_penerima').trim().isLength({ min: 3 }).withMessage('Nama penerima minimal 3 karakter.'),
  body('no_hp').matches(/^(08|\+628)\d{8,12}$/).withMessage('Nomor HP tidak valid.'),
  body('alamat').trim().isLength({ min: 10 }).withMessage('Alamat minimal 10 karakter.'),
  body('items').isArray({ min: 1 }).withMessage('Pesanan minimal berisi 1 produk.'),
  body('items.*.product_id').isInt({ min: 1 }).withMessage('Produk tidak valid.'),
  body('items.*.jumlah_kg').isFloat({ min: 1 }).withMessage('Jumlah minimal 1 kg.'),
];

r.use(auth);
r.get('/summary', role('admin'), c.summary);
r.get('/', c.list);
r.post('/', role('pelanggan', 'reseller'), createRules, v, c.create);
r.post('/:id/payment', role('pelanggan', 'reseller'), upload.single('bukti'), c.payment);
r.patch('/:id/status', role('admin'),
  body('status').isIn(['menunggu_pembayaran', 'dibayar', 'diproses', 'dikirim', 'selesai']).withMessage('Status tidak valid.'),
  v, c.setStatus);

module.exports = r;
