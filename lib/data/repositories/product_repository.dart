import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';
import '../../core/upload.dart';
import '../models/product.dart';

class ProductRepository {
  Dio get _d => ApiClient.instance.dio;

  Future<List<Product>> all() async {
    final r = await _d.get('/products');
    return (r.data as List).map((e) => Product.fromJson(e)).toList();
  }

  /// Admin: tambah (id null) atau ubah produk, foto opsional.
  Future<void> save({int? id, required Map<String, dynamic> data, XFile? foto}) async {
    final form = FormData.fromMap({
      ...data,
      if (foto != null) 'foto': await filePart(foto),
    });
    if (id == null) {
      await _d.post('/products', data: form);
    } else {
      await _d.put('/products/$id', data: form);
    }
  }

  Future<void> delete(int id) async {
    await _d.delete('/products/$id');
  }
}
