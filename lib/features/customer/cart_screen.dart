import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/utils.dart';
import '../../data/repositories/order_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_network_image.dart';

/// Keranjang + form pengiriman dalam satu layar.
class CartScreen extends StatefulWidget {
  final VoidCallback onOrdered;
  const CartScreen({super.key, required this.onOrdered});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _repo = OrderRepository();
  final _k = GlobalKey<FormState>();
  late final _nama = TextEditingController(text: context.read<AuthProvider>().user!.nama);
  late final _hp = TextEditingController(text: context.read<AuthProvider>().user!.noHp ?? '');
  late final _alamat = TextEditingController(text: context.read<AuthProvider>().user!.alamat ?? '');
  bool _busy = false;

  Future<void> _order() async {
    if (!_k.currentState!.validate()) return;
    setState(() => _busy = true);
    final cart = context.read<CartProvider>();
    try {
      await _repo.create(
        nama: _nama.text.trim(),
        hp: _hp.text.trim(),
        alamat: _alamat.text.trim(),
        items: cart.items.values.map((i) => {'product_id': i.product.id, 'jumlah_kg': i.qty}).toList(),
      );
      cart.clear();
      if (!mounted) return;
      snack(context, 'Pesanan dibuat. Silakan transfer lalu unggah bukti.');
      widget.onOrdered();
      return;
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.items.isEmpty) return const Center(child: Text('Keranjang masih kosong.'));
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Keranjang', style: Theme.of(context).textTheme.titleLarge),
      for (final i in cart.items.values)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: SizedBox(width: 48, height: 48, child: AppNetworkImage(url: ApiConfig.img(i.product.foto), radius: 8)),
          title: Text(i.product.nama),
          subtitle: Text('${kg(i.qty)} x ${rupiah(i.price)}'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.remove), onPressed: () => cart.change(i.product.id, -1)),
            IconButton(icon: const Icon(Icons.add), onPressed: () => cart.change(i.product.id, 1)),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => cart.remove(i.product.id)),
          ]),
        ),
      const Divider(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Perkiraan total', style: TextStyle(fontWeight: FontWeight.w700)),
        Text(rupiah(cart.total), style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
      const Text('Harga final dihitung server saat pesanan dibuat.', style: TextStyle(fontSize: 11, color: Colors.black54)),
      const SizedBox(height: 16),
      Text('Pengiriman', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Form(
        key: _k,
        child: Column(children: [
          TextFormField(controller: _nama, decoration: const InputDecoration(labelText: 'Nama penerima'), validator: (v) => vMin(v, 3, 'Nama')),
          const SizedBox(height: 10),
          TextFormField(controller: _hp, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor HP (Opsional)'), validator: vPhone),
          const SizedBox(height: 10),
          TextFormField(controller: _alamat, maxLines: 3, decoration: const InputDecoration(labelText: 'Alamat lengkap'), validator: (v) => vMin(v, 10, 'Alamat')),
        ]),
      ),
      const SizedBox(height: 16),
      FilledButton(onPressed: _busy ? null : _order, child: Text(_busy ? 'Memproses...' : 'Buat pesanan')),
    ]);
  }
}
