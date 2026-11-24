import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/utils.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _k = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _busy = false;

  Future<void> _register() async {
    if (!_k.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthProvider>().register(_nama.text.trim(), _email.text.trim().toLowerCase(), _pw.text);
      if (mounted) Navigator.pop(context); // AuthGate otomatis pindah ke beranda
      return;
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Daftar')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _k,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(labelText: 'Nama lengkap'),
                validator: (v) => vMin(v, 3, 'Nama'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: vEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pw,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Kata sandi'),
                validator: (v) => vMin(v, 6, 'Kata sandi'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pw2,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Ulangi kata sandi'),
                validator: (v) => v == _pw.text ? null : 'Kata sandi tidak sama.',
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _busy ? null : _register, child: Text(_busy ? 'Memproses...' : 'Daftar')),
            ]),
          ),
        ),
      );
}
