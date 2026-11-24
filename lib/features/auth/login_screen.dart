import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_logo.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _k = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _busy = false, _hide = true;

  Future<void> _login() async {
    if (!_k.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthProvider>().login(_email.text.trim().toLowerCase(), _pw.text);
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _k,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Center(child: AppLogo(size: 96)),
                  const SizedBox(height: 12),
                  Text('Dapurku', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                  const Text('Masuk untuk mulai belanja', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: vEmail,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pw,
                    obscureText: _hide,
                    decoration: InputDecoration(
                      labelText: 'Kata sandi',
                      suffixIcon: IconButton(
                        icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                    validator: (v) => vRequired(v, 'Kata sandi'),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: _busy ? null : _login, child: Text(_busy ? 'Memproses...' : 'Masuk')),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Belum punya akun? Daftar'),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}
