import 'dart:convert';
import 'package:http/http.dart' as http;

class Cat {
  final String id;
  final String name;
  final String origin;

  Cat({required this.id, required this.name, required this.origin});

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'origin': origin};
  }
}

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
