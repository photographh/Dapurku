import 'package:flutter/material.dart';
import '../customer/profile_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _i = 0;
  static const _pages = <Widget>[
    AdminDashboardScreen(),
    AdminProductsScreen(),
    AdminOrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: _pages[_i]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _i,
          onDestinationSelected: (i) => setState(() => _i = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Produk'),
            NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'Pesanan'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
          ],
        ),
      );
}
