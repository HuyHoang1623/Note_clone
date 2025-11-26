import 'dart:convert';
import 'package:http/http.dart' as http;

class CatApi {
  static const String baseUrl = 'https://api.thecatapi.com/v1';
  static const String apiKey =
      "live_5s0Apt2FK2G0Z61ZgmWYA5zYHppniCnLq4zcwKwZPvASQYztP6EyZ5efNFj2ZL0t";

  static Future<List<String>> fetchCatImages({int limit = 100}) async {
    final url = Uri.parse('$baseUrl/images/search?limit=$limit');

    try {
      final response = await http.get(url, headers: {"x-api-key": apiKey});

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map<String>((item) => item['url'] as String).toList();
      } else {
        throw Exception(
          "Không thể lấy ảnh mèo. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Đã xảy ra lỗi khi lấy dữ liệu ảnh: $e");
    }
  }

  static Future<List<CatBreed>> fetchCatBreeds() async {
    final url = Uri.parse('$baseUrl/breeds');

    try {
      final response = await http.get(url, headers: {"x-api-key": apiKey});

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map<CatBreed>((item) => CatBreed.fromJson(item)).toList();
      } else {
        throw Exception(
          "Không thể lấy danh sách giống mèo. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Đã xảy ra lỗi khi lấy dữ liệu giống mèo: $e");
    }
  }
}

class CatBreed {
  final String id;
  final String name;
  final String? origin;
  final String? temperament;

  CatBreed({
    required this.id,
    required this.name,
    this.origin,
    this.temperament,
  });

  factory CatBreed.fromJson(Map<String, dynamic> json) {
    return CatBreed(
      id: json['id'],
      name: json['name'],
      origin: json['origin'],
      temperament: json['temperament'],
    );
  }
}
