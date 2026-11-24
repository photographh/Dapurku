import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/models/product.dart';

class CartItem {
  final Product product;
  double qty;
  CartItem(this.product, this.qty);

  int get price => product.priceFor(qty);
  double get subtotal => price * qty;
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> items = {};

  double get total => items.values.fold(0.0, (s, i) => s + i.subtotal);

  void add(Product p, double q) {
    final cur = items[p.id]?.qty ?? 0;
    items[p.id] = CartItem(p, min(cur + q, p.stok));
    notifyListeners();
  }

  void change(int id, double d) {
    final i = items[id];
    if (i == null) return;
    final q = i.qty + d;
    if (q < 1) {
      items.remove(id);
    } else {
      i.qty = min(q, i.product.stok);
    }
    notifyListeners();
  }

  void remove(int id) {
    items.remove(id);
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }
}
