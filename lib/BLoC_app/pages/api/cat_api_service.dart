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

    final response = await req.send();
    final resp = await response.stream.bytesToString();

    if (response.statusCode != 201) return null;

    final data = json.decode(resp);
    if (data['id'] == null || data['url'] == null) return null;

    return Cat.fromJson(data);
  }

  Future<void> deleteImage(String id) async {
    final url = Uri.parse('$_baseUrl/$id');
    await http.delete(url, headers: {'x-api-key': _apiKey});
  }

  Future<int?> voteImage(String imageId, int value, {String? subId}) async {
    final url = Uri.parse(_voteUrl);
    final body = {"image_id": imageId, "value": value};
    if (subId != null) body["sub_id"] = subId;

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
      body: json.encode(body),
    );

    if (res.statusCode != 201 && res.statusCode != 200) return null;

    final data = json.decode(res.body);
    return data['id'];
  }

  Future<Map<String, dynamic>?> getVoteById(int voteId) async {
    final url = Uri.parse('$_voteUrl/$voteId');
    final res = await http.get(url, headers: {'x-api-key': _apiKey});
    if (res.statusCode != 200) return null;
    return json.decode(res.body);
  }

  Future<bool> deleteVote(int voteId) async {
    final url = Uri.parse('$_voteUrl/$voteId');
    final res = await http.delete(url, headers: {'x-api-key': _apiKey});
    return res.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> getAllVotes() async {
    final url = Uri.parse(_voteUrl);
    final res = await http.get(url, headers: {'x-api-key': _apiKey});
    if (res.statusCode != 200) return [];
    return List<Map<String, dynamic>>.from(json.decode(res.body));
  }
}
