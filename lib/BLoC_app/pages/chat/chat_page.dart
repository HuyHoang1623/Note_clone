import 'package:flutter/material.dart';
import 'package:note_clone/core/models/user.dart';
class ChatPage extends StatefulWidget {
  final UserModel receiverUser;
  final UserModel currentUser;

  const ChatPage({
    required this.receiverUser,
    required this.currentUser,
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUser.name ?? 'Người dùng'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
