const { validationResult } = require('express-validator');

module.exports = (req, res, next) => {
  const e = validationResult(req);
  if (e.isEmpty()) return next();
  const errors = e.array();
  res.status(400).json({
    message: errors[0].msg,
    errors: errors.map((x) => ({ field: x.path, message: x.msg })),
  });
};
