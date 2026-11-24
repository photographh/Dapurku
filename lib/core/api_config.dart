class ApiConfig {
  static const baseUrl = 'http://10.20.242.220:3000';

  static String img(String? file) =>
      (file == null || file.isEmpty) ? '' : '$baseUrl/uploads/$file';
}