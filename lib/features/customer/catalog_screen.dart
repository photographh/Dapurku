import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/async_body.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _repo = ProductRepository();
  late Future<List<Product>> _f = _repo.all();
  String _cat = 'semua';
  static const _cats = {'semua': 'Semua', 'bawang': 'Bawang', 'bumbu': 'Bumbu', 'paket': 'Paket'};

  Future<void> _reload() async {
    setState(() {
      _f = _repo.all();
    });
    await _f;
  }

  Widget _header() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AppLogo(type: LogoType.full, size: 36),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFFAC775), borderRadius: BorderRadius.circular(12)),
              child: const Text('Beli 10Kg Lebih Untung', style: TextStyle(fontSize: 11, color: Color(0xFF412402), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Text('Bumbu Dapur,\nharga grosir',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: cs.onPrimary, height: 1.1)),
          ]),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final e in _cats.entries)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(e.value),
                  selected: _cat == e.key,
                  onSelected: (_) => setState(() => _cat = e.key),
                ),
              ),
          ]),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => AsyncBody<List<Product>>(
        future: _f,
        onRefresh: _reload,
        builder: (all) {
          final list = all.where((p) => _cat == 'semua' || p.kategori == _cat).toList();
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header()),
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => ProductCard(
                      p: list[i],
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: list[i]))),
                    ),
                    childCount: list.length,
                  ),
                ),
              ),
            ],
          );
        },
      );
}
