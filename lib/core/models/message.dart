import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderID;
  final String text;
  final Timestamp timestamp;
  final String? senderName;
  final String? senderPhotoUrl;

  MessageModel({
    required this.senderID,
    required this.text,
    required this.timestamp,
    this.senderName,
    this.senderPhotoUrl,
  });

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      senderID: data['senderID'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      senderName: data['senderName'],
      senderPhotoUrl: data['senderPhotoUrl'],
    );
  }
}
