class User {
  final int id;
  final String nama, email, role;
  final String? noHp, alamat, foto;

  const User({required this.id, required this.nama, required this.email, required this.role, this.noHp, this.alamat, this.foto});

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'],
        nama: j['nama'],
        email: j['email'],
        role: j['role'],
        noHp: j['no_hp'],
        alamat: j['alamat'],
        foto: j['foto'],
      );

  bool get isAdmin => role == 'admin';
}
