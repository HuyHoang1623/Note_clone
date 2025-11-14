import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_clone/core/models/user.dart';

class Workspace {
  final String id;
  final String name;
  final String ownerId;
  final List<UserModel> members;
  final DateTime createdAt;

  Workspace({
    String? id,
    required this.name,
    required this.ownerId,
    required this.members,
    required this.createdAt,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      name: json['name'],
      ownerId: json['ownerId'],
      members: (json['members'] as List)
          .map((m) => UserModel.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'members': members.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Workspace.fromFirestore(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      name: json['name'],
      ownerId: json['ownerId'],
      members: (json['members'] as List)
          .map((m) => UserModel.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'members': members.map((m) => m.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
