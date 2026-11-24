const r = require('express').Router();
const { body } = require('express-validator');
const v = require('../middleware/validate');
const c = require('../controllers/auth.controller');

const email = body('email').trim().toLowerCase().isEmail().withMessage('Email tidak valid.');

r.post('/register', [
  body('nama').trim().isLength({ min: 3 }).withMessage('Nama minimal 3 karakter.'),
  email,
  body('password').isLength({ min: 6 }).withMessage('Password minimal 6 karakter.'),
], v, c.register);

r.post('/login', [email, body('password').notEmpty().withMessage('Password wajib diisi.')], v, c.login);

module.exports = r;
