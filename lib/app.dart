import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'features/admin/admin_shell.dart';
import 'features/auth/login_screen.dart';
import 'features/customer/customer_shell.dart';
import 'providers/auth_provider.dart';
import 'widgets/app_logo.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Dapurku',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const AuthGate(),
      );
}

/// Menentukan halaman awal: login, shell pelanggan/reseller, atau shell admin.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.ready) return const Scaffold(body: Center(child: AppLogo(size: 80)));
    if (auth.user == null) return const LoginScreen();
    return auth.user!.isAdmin ? const AdminShell() : const CustomerShell();
  }
}
