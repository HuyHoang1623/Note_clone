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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String?,
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      provider: json['provider'] as String? ?? 'email',
      createdAt: json['createdAt'] is Timestamp
          ? json['createdAt'] as Timestamp
          : (json['createdAt'] != null
                ? Timestamp.fromDate(
                    DateTime.parse(json['createdAt'].toString()),
                  )
                : null),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: data['uid'] as String? ?? doc.id,
      email: data['email'] as String?,
      name: data['name'] as String?,
      photoUrl: data['photoUrl'] as String?,
      provider: data['provider'] as String? ?? 'email',
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : (data['createdAt'] != null
                ? Timestamp.fromDate(
                    DateTime.parse(data['createdAt'].toString()),
                  )
                : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'provider': provider,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'provider': provider,
      'createdAt': createdAt != null
          ? createdAt!.toDate().toIso8601String()
          : null,
    };
  }

