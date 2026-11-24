import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/utils.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import '../../widgets/async_body.dart';
import '../../widgets/order_card.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _repo = OrderRepository();
  late Future<List<Order>> _f = _repo.list();

  Future<void> _reload() async {
    setState(() {
      _f = _repo.list();
    });
    await _f;
  }

  Future<void> _set(Order o, String status) async {
    try {
      await _repo.setStatus(o.id, status);
      _reload();
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
  }

  Widget _one(Order o, String next, String label) =>
      FilledButton(onPressed: () => _set(o, next), child: Text(label));

  Widget? _actions(Order o) {
    switch (o.status) {
      case 'menunggu_konfirmasi':
        return Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => _set(o, 'menunggu_pembayaran'), child: const Text('Tolak'))),
          const SizedBox(width: 8),
          Expanded(child: FilledButton(onPressed: () => _set(o, 'dibayar'), child: const Text('Terima'))),
        ]);
      case 'dibayar':
        return _one(o, 'diproses', 'Proses pesanan');
      case 'diproses':
        return _one(o, 'dikirim', 'Tandai dikirim');
      case 'dikirim':
        return _one(o, 'selesai', 'Selesaikan');
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) => AsyncBody<List<Order>>(
        future: _f,
        onRefresh: _reload,
        builder: (orders) => ListView(padding: const EdgeInsets.all(16), children: [
          Text('Pesanan masuk', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (orders.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Belum ada pesanan.'))),
          for (final o in orders) OrderCard(order: o, actions: _actions(o)),
        ]),
      );
}
