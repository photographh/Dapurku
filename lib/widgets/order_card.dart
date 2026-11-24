import 'package:flutter/material.dart';
import '../core/api_config.dart';
import '../core/utils.dart';
import '../data/models/order.dart';
import 'app_network_image.dart';

/// Kartu pesanan, dipakai pelanggan dan admin. [actions] = tombol di bawah kartu.
class OrderCard extends StatelessWidget {
  final Order order;
  final Widget? actions;
  const OrderCard({super.key, required this.order, this.actions});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cur = orderSteps.indexOf(order.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Pesanan #${order.id}', style: const TextStyle(fontWeight: FontWeight.w700))),
            Text(rupiah(order.total), style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
          if (order.userNama != null) Text(order.userNama!, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(order.items.map((i) => '${i.nama} ${kg(i.qty)}').join(', '),
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 10),
          Wrap(spacing: 4, runSpacing: 4, children: [
            for (var k = 0; k < orderSteps.length; k++)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: k < cur ? const Color(0xFFC0DD97) : (k == cur ? cs.primary : Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusLabel(orderSteps[k]),
                    style: TextStyle(fontSize: 10, color: k == cur ? cs.onPrimary : Colors.black87)),
              ),
          ]),
          if (order.bukti != null) ...[
            const SizedBox(height: 10),
            AppNetworkImage(url: ApiConfig.img(order.bukti), width: 110, height: 110),
          ],
          if (actions != null) ...[const SizedBox(height: 10), actions!],
        ]),
      ),
    );
  }
}
