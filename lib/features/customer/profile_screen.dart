import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/utils.dart';
import '../../data/repositories/auth_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_network_image.dart';

class _Field {
  final String label;
  final TextEditingController c;
  final bool obscure;
  final String? Function(String?)? v;
  _Field(this.label, this.c, {this.obscure = false, this.v});
}

/// Dipakai pelanggan, reseller, dan admin.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = AuthRepository();

  Future<void> _photo() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x == null) return;
    try {
      await _repo.uploadPhoto(x);
      if (mounted) await context.read<AuthProvider>().refresh();
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
  }

  Future<void> _form(String title, List<_Field> fs, Future<void> Function() onOk) async {
    final k = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(title),
        content: Form(
          key: k,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final f in fs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: f.c,
                    obscureText: f.obscure,
                    decoration: InputDecoration(labelText: f.label),
                    validator: f.v,
                  ),
                ),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (!k.currentState!.validate()) return;
              try {
                await onOk();
                if (d.mounted) Navigator.pop(d);
              } catch (e) {
                if (mounted) snack(context, errMsg(e));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    final u = context.read<AuthProvider>().user!;
    final nama = TextEditingController(text: u.nama);
    final hp = TextEditingController(text: u.noHp ?? '');
    final alamat = TextEditingController(text: u.alamat ?? '');
    _form('Edit profil', [
      _Field('Nama', nama, v: (v) => vMin(v, 3, 'Nama')),
      _Field('Nomor HP', hp, v: vPhone),
      _Field('Alamat utama', alamat, v: (v) => vMin(v, 10, 'Alamat')),
    ], () async {
      await _repo.updateProfile(nama.text.trim(), hp.text.trim(), alamat.text.trim());
      if (mounted) {
        await context.read<AuthProvider>().refresh();
        if (mounted) snack(context, 'Profil diperbarui.');
      }
    });
  }

  void _changePassword() {
    final lama = TextEditingController();
    final baru = TextEditingController();
    _form('Ganti password', [
      _Field('Password lama', lama, obscure: true, v: (v) => vRequired(v, 'Password lama')),
      _Field('Password baru', baru, obscure: true, v: (v) => vMin(v, 6, 'Password baru')),
    ], () async {
      await _repo.changePassword(lama.text, baru.text);
      if (mounted) snack(context, 'Password diganti.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = context.watch<AuthProvider>().user!;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Center(
        child: GestureDetector(
          onTap: _photo,
          child: SizedBox(
            width: 96,
            height: 96,
            child: AppNetworkImage(url: ApiConfig.img(u.foto), radius: 48, fallbackIcon: Icons.person),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Center(child: Text('Ketuk foto untuk mengganti', style: TextStyle(fontSize: 11, color: Colors.black54))),
      ),
      const SizedBox(height: 8),
      Center(child: Text(u.nama, style: Theme.of(context).textTheme.headlineSmall)),
      Center(child: Chip(label: Text(u.role))),
      ListTile(leading: const Icon(Icons.email_outlined), title: Text(u.email)),
      ListTile(leading: const Icon(Icons.phone_outlined), title: Text(u.noHp ?? '-')),
      ListTile(leading: const Icon(Icons.home_outlined), title: Text(u.alamat ?? '-')),
      const SizedBox(height: 12),
      OutlinedButton(onPressed: _editProfile, child: const Text('Edit profil')),
      const SizedBox(height: 8),
      OutlinedButton(onPressed: _changePassword, child: const Text('Ganti password')),
      const SizedBox(height: 8),
      FilledButton.tonal(
        onPressed: () {
          context.read<CartProvider>().clear();
          context.read<AuthProvider>().logout();
        },
        child: const Text('Keluar'),
      ),
    ]);
  }
}
