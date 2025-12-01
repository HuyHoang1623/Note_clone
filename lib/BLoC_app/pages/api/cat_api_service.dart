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

  static Future<Cat> createCat(String name, String origin) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'name': name, 'origin': origin}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Cat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create cat');
    }
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
