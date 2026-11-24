require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

app.use('/auth', require('./routes/auth.routes'));
app.use('/products', require('./routes/product.routes'));
app.use('/orders', require('./routes/order.routes'));
app.use('/profile', require('./routes/profile.routes'));

app.use((req, res) => res.status(404).json({ message: 'Endpoint tidak ditemukan.' }));
app.use(require('./middleware/error'));

const port = process.env.PORT || 3000;

app.listen(port, '0.0.0.0', () => {
  console.log(`API jalan di port ${port}`);
});