import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/utils.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../widgets/app_network_image.dart';

/// Form tambah/ubah produk. Admin cukup isi harga dasar;
/// harga bertingkat dibuat otomatis oleh server.
class AdminProductForm extends StatefulWidget {
  final Product? product;
  const AdminProductForm({super.key, this.product});
  @override
  State<AdminProductForm> createState() => _AdminProductFormState();
}

class _AdminProductFormState extends State<AdminProductForm> {
  final _repo = ProductRepository();
  final _k = GlobalKey<FormState>();
  late final _nama = TextEditingController(text: widget.product?.nama);
  late final _harga = TextEditingController(text: widget.product?.hargaDasar.toString());
  late final _stok = TextEditingController(text: widget.product?.stok.toString());
  late final _desc = TextEditingController(text: widget.product?.deskripsi);
  late String _kat = widget.product?.kategori ?? 'bawang';
  XFile? _foto;
  Uint8List? _bytes;
  bool _busy = false;

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x == null) return;
    final b = await x.readAsBytes();
    setState(() {
      _foto = x;
      _bytes = b;
    });
  }

  Future<void> _save() async {
    if (!_k.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await _repo.save(
        id: widget.product?.id,
        foto: _foto,
        data: {
          'nama': _nama.text.trim(),
          'kategori': _kat,
          'harga_dasar': _harga.text.trim(),
          'stok_kg': _stok.text.trim(),
          'deskripsi': _desc.text.trim(),
        },
      );
      if (mounted) Navigator.pop(context, true);
      return;
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.product == null ? 'Tambah produk' : 'Ubah produk')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _k,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              GestureDetector(
                onTap: _pick,
                child: SizedBox(
                  height: 160,
                  child: _bytes != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.memory(_bytes!, fit: BoxFit.cover))
                      : AppNetworkImage(url: ApiConfig.img(widget.product?.foto), radius: 14, fallbackIcon: Icons.add_a_photo_outlined),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('Ketuk gambar untuk memilih foto', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black54)),
              ),
              TextFormField(controller: _nama, decoration: const InputDecoration(labelText: 'Nama produk'), validator: (v) => vMin(v, 3, 'Nama')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _kat,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: const [
                  DropdownMenuItem(value: 'bawang', child: Text('Bawang')),
                  DropdownMenuItem(value: 'bumbu', child: Text('Bumbu')),
                  DropdownMenuItem(value: 'paket', child: Text('Paket')),
                ],
                onChanged: (v) => setState(() => _kat = v!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _harga,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga dasar per kg (Rp)'),
                validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0 ? null : 'Harga harus angka positif.',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _stok,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Stok (kg)'),
                validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Stok tidak boleh negatif.',
              ),
              const SizedBox(height: 10),
              TextFormField(controller: _desc, decoration: const InputDecoration(labelText: 'Deskripsi singkat')),
              const SizedBox(height: 20),
              FilledButton(onPressed: _busy ? null : _save, child: Text(_busy ? 'Menyimpan...' : 'Simpan')),
            ]),
          ),
        ),
      );
}