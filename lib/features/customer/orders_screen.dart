import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';
import '../../core/utils.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import '../../widgets/async_body.dart';
import '../../widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _repo = OrderRepository();
  late Future<List<Order>> _f = _repo.list();

  Future<void> _reload() async {
    setState(() {
      _f = _repo.list();
    });
    await _f;
  }

  Future<void> _upload(int id) async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x == null) return;
    try {
      await _repo.uploadBukti(id, x);
      if (mounted) snack(context, 'Bukti transfer terkirim.');
      _reload();
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
  }

  @override
  Widget build(BuildContext context) => AsyncBody<List<Order>>(
        future: _f,
        onRefresh: _reload,
        builder: (orders) => ListView(padding: const EdgeInsets.all(16), children: [
          Text('Pesanan saya', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (orders.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Belum ada pesanan.'))),
          for (final o in orders)
            OrderCard(
              order: o,
              actions: o.status == 'menunggu_pembayaran'
                  ? OutlinedButton.icon(
                      icon: const Icon(Icons.upload_outlined),
                      label: const Text('Unggah bukti transfer'),
                      onPressed: () => _upload(o.id),
                    )
                  : null,
            ),
        ]),
      );
}