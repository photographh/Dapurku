import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final _store = const FlutterSecureStorage();
  final _repo = AuthRepository();

  User? user;
  bool ready = false;

  /// Dipanggil sekali saat aplikasi dibuka: pulihkan sesi dari token tersimpan.
  Future<void> init() async {
    final t = await _store.read(key: 'token');
    if (t != null) {
      ApiClient.instance.token = t;
      try {
        user = await _repo.me();
      } catch (_) {
        await logout();
      }
    }
    ready = true;
    notifyListeners();
  }

  Future<void> login(String email, String pw) async {
    final d = await _repo.login(email, pw);
    ApiClient.instance.token = d['token'];
    await _store.write(key: 'token', value: d['token']);
    user = User.fromJson(d['user']);
    notifyListeners();
  }

  Future<void> register(String nama, String email, String pw) async {
    await _repo.register(nama, email, pw);
    await login(email, pw);
  }

  Future<void> refresh() async {
    user = await _repo.me();
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.delete(key: 'token');
    ApiClient.instance.token = null;
    user = null;
    notifyListeners();
  }
}
