import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/utils.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/async_body.dart';
import 'admin_product_form.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});
  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _repo = ProductRepository();
  late Future<List<Product>> _f = _repo.all();

  Future<void> _reload() async {
    setState(() {
      _f = _repo.all();
    });
    await _f;
  }

  Future<void> _open([Product? p]) async {
    final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => AdminProductForm(product: p)));
    if (ok == true) _reload();
  }

  Future<void> _delete(Product p) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('${p.nama} akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await _repo.delete(p.id);
      _reload();
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _open(),
          icon: const Icon(Icons.add),
          label: const Text('Tambah produk'),
        ),
        body: AsyncBody<List<Product>>(
          future: _f,
          onRefresh: _reload,
          builder: (list) => ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), children: [
            Text('Produk', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final p in list)
              Card(
                child: ListTile(
                  leading: SizedBox(width: 48, height: 48, child: AppNetworkImage(url: ApiConfig.img(p.foto), radius: 8)),
                  title: Text(p.nama),
                  subtitle: Text('${rupiah(p.hargaDasar)}/kg - stok ${kg(p.stok)}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _open(p)),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(p)),
                  ]),
                ),
              ),
          ]),
        ),
      );
}
