import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_config.dart';
import '../../core/utils.dart';
import '../../data/models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  double _q = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final price = p.priceFor(_q);
    final active = p.tiers.lastIndexWhere((t) => _q >= t.minKg);
    return Scaffold(
      appBar: AppBar(title: Text(p.nama)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        AspectRatio(aspectRatio: 16 / 10, child: AppNetworkImage(url: ApiConfig.img(p.foto), radius: 16)),
        const SizedBox(height: 12),
        Text(p.nama, style: Theme.of(context).textTheme.headlineSmall),
        Text(p.deskripsi),
        Text('Stok ${kg(p.stok)}', style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 16),
        Text('Harga bertingkat', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        for (var i = 0; i < p.tiers.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: i == active ? const Color(0xFFC0DD97) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${kg(p.tiers[i].minKg)} ke atas'),
              Text('${rupiah(p.tiers[i].harga)}/kg', style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _q > 1 ? () => setState(() => _q -= 1) : null,
          ),
          Text(kg(_q), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _q + 1 <= p.stok ? () => setState(() => _q += 1) : null,
          ),
        ]),
        Text('Subtotal ${rupiah(price * _q)}', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: p.stok < 1
              ? null
              : () {
                  context.read<CartProvider>().add(p, _q);
                  snack(context, '${p.nama} masuk keranjang.');
                  Navigator.pop(context);
                },
          child: Text(p.stok < 1 ? 'Stok habis' : 'Tambah ke keranjang'),
        ),
      ]),
    );
  }
}
