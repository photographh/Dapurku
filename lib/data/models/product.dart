double _d(dynamic v) => double.parse(v.toString());

class Tier {
  final double minKg;
  final int harga;
  const Tier(this.minKg, this.harga);
}

class Product {
  final int id, hargaDasar;
  final String nama, kategori, deskripsi;
  final double stok;
  final String? foto;
  final List<Tier> tiers; // terurut naik, khusus role si pengguna

  const Product({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.deskripsi,
    required this.hargaDasar,
    required this.stok,
    required this.tiers,
    this.foto,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'],
        nama: j['nama'],
        kategori: j['kategori'],
        deskripsi: j['deskripsi'] ?? '',
        hargaDasar: j['harga_dasar'],
        stok: _d(j['stok_kg']),
        foto: j['foto'],
        tiers: (j['tiers'] as List).map((t) => Tier(_d(t['min_kg']), t['harga_per_kg'] as int)).toList(),
      );

  /// Harga per kg untuk jumlah tertentu. Hanya untuk tampilan;
  /// harga final dihitung server saat pesanan dibuat.
  int priceFor(double qty) {
    var h = tiers.isEmpty ? hargaDasar : tiers.first.harga;
    for (final t in tiers) {
      if (qty >= t.minKg) h = t.harga;
    }
    return h;
  }
}
