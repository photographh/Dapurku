import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _rp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
String rupiah(num n) => _rp.format(n);
String kg(num n) => '${n % 1 == 0 ? n.toInt() : n} kg';

const orderSteps = ['menunggu_pembayaran', 'menunggu_konfirmasi', 'dibayar', 'diproses', 'dikirim', 'selesai'];
String statusLabel(String s) {
  final t = s.replaceAll('_', ' ');
  return t[0].toUpperCase() + t.substring(1);
}

// Validator form (dipakai di TextFormField.validator)
String? vRequired(String? v, String f) => (v == null || v.trim().isEmpty) ? '$f wajib diisi.' : null;
String? vMin(String? v, int n, String f) => (v ?? '').trim().length >= n ? null : '$f minimal $n karakter.';
String? vEmail(String? v) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '') ? null : 'Email tidak valid.';
String? vPhone(String? v) =>
    RegExp(r'^(08|\+628)\d{8,12}$').hasMatch(v?.trim() ?? '') ? null : 'Nomor HP tidak valid (contoh 08123456789).';

void snack(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));
