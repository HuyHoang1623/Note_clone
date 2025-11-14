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
