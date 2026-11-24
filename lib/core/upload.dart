import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

/// Ubah foto pilihan pengguna jadi bagian multipart.
/// Pakai bytes supaya jalan di semua platform (Android, iOS, Windows, web).
Future<MultipartFile> filePart(XFile x) async {
  final ok = RegExp(r'\.(jpe?g|png|webp)$', caseSensitive: false).hasMatch(x.name);
  return MultipartFile.fromBytes(await x.readAsBytes(), filename: ok ? x.name : '${x.name}.jpg');
}
