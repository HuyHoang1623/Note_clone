import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'cat_model.dart';

class CatApiService {
  static const String _apiKey =
      'live_5s0Apt2FK2G0Z61ZgmWYA5zYHppniCnLq4zcwKwZPvASQYztP6EyZ5efNFj2ZL0t';
  static const String _baseUrl = 'https://api.thecatapi.com/v1/images';

  Future<List<Cat>> fetchImages() async {
    final url = Uri.parse('$_baseUrl?limit=30');
    final res = await http.get(url, headers: {'x-api-key': _apiKey});
    final List data = json.decode(res.body);
    return data.map((e) => Cat.fromJson(e)).toList();
  }

  Future<Cat?> uploadImage(File file) async {
    final uri = Uri.parse('$_baseUrl/upload');
    final req = http.MultipartRequest('POST', uri);
    req.headers['x-api-key'] = _apiKey;

    req.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );
  }

    final response = await req.send();
    final resp = await response.stream.bytesToString();

class CatService {
  static const String baseUrl =
      'https://692955919d311cddf3491497.mockapi.io/api/v1/cat';

  static Future<List<Cat>> fetchCats() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => Cat.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch cats');
    }
  }
    if (response.statusCode != 201) return null;

    final data = json.decode(resp);
    if (data['id'] == null || data['url'] == null) return null;

    return Cat.fromJson(data);
  }

  static Future<void> deleteCat(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception('Failed to delete cat');
    }
  }
}
