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
