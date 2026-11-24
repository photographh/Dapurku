double _d(dynamic v) => double.parse(v.toString());

class OrderItem {
  final String nama;
  final double qty;
  final int harga;
  const OrderItem(this.nama, this.qty, this.harga);

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(j['nama'], _d(j['jumlah_kg']), j['harga_per_kg']);
}

class Order {
  final int id, total;
  final String status, alamat, namaPenerima, noHp;
  final String? bukti, userNama;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.total,
    required this.status,
    required this.alamat,
    required this.namaPenerima,
    required this.noHp,
    required this.items,
    this.bukti,
    this.userNama,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'],
        total: j['total'],
        status: j['status'],
        alamat: j['alamat'],
        namaPenerima: j['nama_penerima'],
        noHp: j['no_hp'],
        bukti: j['bukti_transfer'],
        userNama: j['user_nama'],
        items: (j['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      );
}
