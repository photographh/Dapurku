import 'package:flutter/material.dart';
import '../../core/utils.dart';
import '../../data/repositories/order_repository.dart';
import '../../widgets/async_body.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _repo = OrderRepository();
  late Future<Map<String, dynamic>> _f = _repo.summary();

  Future<void> _reload() async {
    setState(() {
      _f = _repo.summary();
    });
    await _f;
  }

  Widget _stat(String label, dynamic value, Color bg, Color fg) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11, color: fg)),
            Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: fg)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => AsyncBody<Map<String, dynamic>>(
        future: _f,
        onRefresh: _reload,
        builder: (s) => ListView(padding: const EdgeInsets.all(16), children: [
          Text('Dashboard', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFF4A1B0C), borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Omzet terkonfirmasi', style: TextStyle(color: Color(0xFFF0997B), fontSize: 12)),
              Text(rupiah(s['omzet']),
                  style: const TextStyle(color: Color(0xFFFAC775), fontSize: 26, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _stat('Pesanan', s['total'], const Color(0xFF9FE1CB), const Color(0xFF04342C)),
            _stat('Perlu dicek', s['perlu_dicek'], const Color(0xFFFAC775), const Color(0xFF412402)),
            _stat('Stok tipis', s['stok_tipis'], const Color(0xFFF7C1C1), const Color(0xFF501313)),
          ]),
        ]),
      );
}
