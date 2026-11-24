import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

/// Kerangka pelanggan/reseller: 4 tab dengan menu di bawah.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});
  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final n = context.watch<CartProvider>().items.length;
    final pages = <Widget>[
      const CatalogScreen(),
      CartScreen(onOrdered: () => setState(() => _i = 2)),
      const OrdersScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_i]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (i) => setState(() => _i = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Katalog'),
          NavigationDestination(
            icon: Badge(isLabelVisible: n > 0, label: Text('$n'), child: const Icon(Icons.shopping_cart_outlined)),
            label: 'Keranjang',
          ),
          const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Pesanan'),
          const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
