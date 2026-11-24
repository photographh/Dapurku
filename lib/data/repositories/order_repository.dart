import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';
import '../../core/upload.dart';
import '../models/order.dart';

class OrderRepository {
  Dio get _d => ApiClient.instance.dio;

  Future<void> create({
    required String nama,
    required String hp,
    required String alamat,
    required List<Map<String, dynamic>> items,
  }) async {
    await _d.post('/orders', data: {'nama_penerima': nama, 'no_hp': hp, 'alamat': alamat, 'items': items});
  }

  Future<List<Order>> list() async {
    final r = await _d.get('/orders');
    return (r.data as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> summary() async => (await _d.get('/orders/summary')).data;

  Future<void> uploadBukti(int id, XFile file) async {
    await _d.post('/orders/$id/payment', data: FormData.fromMap({'bukti': await filePart(file)}));
  }

  Future<void> setStatus(int id, String status) async {
    await _d.patch('/orders/$id/status', data: {'status': status});
  }
}
