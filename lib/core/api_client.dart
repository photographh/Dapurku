import 'package:dio/dio.dart';
import 'api_config.dart';

/// Satu klien HTTP untuk seluruh aplikasi. Token ditempel otomatis.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? token;

  late final Dio dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ))
    ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      if (token != null) o.headers['Authorization'] = 'Bearer $token';
      h.next(o);
    }));
}

/// Ambil pesan error yang enak dibaca dari exception apa pun.
/// Ambil pesan error yang enak dibaca dari exception apa pun.
String errMsg(Object e) {
  print('ERROR: $e'); // sementara, buat debug
  if (e is DioException) {
    final d = e.response?.data;
    if (d is Map && d['message'] != null) return d['message'].toString();
    return 'Tidak bisa terhubung ke server.';
  }
  return 'Terjadi kesalahan.';
}