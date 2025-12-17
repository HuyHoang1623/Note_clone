import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_clone/core/models/user.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  Future<void> sendMessage(
    UserModel senderUser,
    String receiverId,
    String message,
  ) async {
    if (message.trim().isEmpty) return;

    final chatRoomId = getChatRoomId(senderUser.uid, receiverId);

    Map<String, dynamic> messageData = {
      'sender_id': senderUser.uid,
      'sender_name': senderUser.name,
      'sender_photoUrl': senderUser.photoUrl,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'users': [senderUser.uid, receiverId],
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
      'lastMessageSenderId': senderUser.uid,
    }, SetOptions(merge: true));
  }

