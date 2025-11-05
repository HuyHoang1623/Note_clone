import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? name;
  final String? photoUrl;
  final String provider;
  final Timestamp? createdAt;

  const UserModel({
    required this.uid,
    this.email,
    this.name,
    this.photoUrl,
    this.provider = 'email',
    this.createdAt,
  });
