import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';
import '../../core/upload.dart';
import '../models/user.dart';

/// Login, register, dan profil.
class AuthRepository {
  Dio get _d => ApiClient.instance.dio;

  Future<Map<String, dynamic>> login(String email, String pw) async {
    final r = await _d.post('/auth/login', data: {'email': email, 'password': pw});
    return r.data;
  }

  Future<void> register(String nama, String email, String pw) async {
    await _d.post('/auth/register', data: {'nama': nama, 'email': email, 'password': pw});
  }

  Future<User> me() async => User.fromJson((await _d.get('/profile')).data);

  Future<void> updateProfile(String nama, String hp, String alamat) async {
    await _d.put('/profile', data: {'nama': nama, 'no_hp': hp, 'alamat': alamat});
  }

  Future<void> uploadPhoto(XFile file) async {
    await _d.post('/profile/photo', data: FormData.fromMap({'foto': await filePart(file)}));
  }

  Future<void> changePassword(String lama, String baru) async {
    await _d.put('/profile/password', data: {'password_lama': lama, 'password_baru': baru});
  }
}
