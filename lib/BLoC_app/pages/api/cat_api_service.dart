import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'cat_model.dart';

class CatApiService {
  static const String _apiKey =
      'live_5s0Apt2FK2G0Z61ZgmWYA5zYHppniCnLq4zcwKwZPvASQYztP6EyZ5efNFj2ZL0t';

  static const String _baseUrl = 'https://api.thecatapi.com/v1/images';
  static const String _voteUrl = 'https://api.thecatapi.com/v1/votes';

  static const String userId = "user_001";

  Future<List<Cat>> fetchImages() async {
    final url = Uri.parse('$_baseUrl?limit=30');
    final response = await http.get(url, headers: {'x-api-key': _apiKey});
    final List data = json.decode(response.body);
    return data.map((e) => Cat.fromJson(e)).toList();
  }

  Future<Cat?> uploadImage(File file) async {
    final uri = Uri.parse('$_baseUrl/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['x-api-key'] = _apiKey;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 201) return null;

    return Cat.fromJson(json.decode(body));
  }

  Future<void> deleteImage(String id) async {
    final url = Uri.parse('$_baseUrl/$id');
    await http.delete(url, headers: {'x-api-key': _apiKey});
  }

  Future<int?> voteImage(String imageId, int value) async {
    final url = Uri.parse(_voteUrl);
    final body = {"image_id": imageId, "value": value, "user_id": userId};

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
      body: json.encode(body),
    );

    if (response.statusCode != 201 && response.statusCode != 200) return null;

    return json.decode(response.body)['id'];
  }

  Future<bool> deleteVote(int voteId) async {
    final url = Uri.parse('$_voteUrl/$voteId');
    final response = await http.delete(url, headers: {'x-api-key': _apiKey});
    return response.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> getAllVotes() async {
    final url = Uri.parse('$_voteUrl?user_id=$userId');
    final response = await http.get(url, headers: {'x-api-key': _apiKey});
    if (response.statusCode != 200) return [];
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }
}
