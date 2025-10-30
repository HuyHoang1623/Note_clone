import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_clone/core/cloud_storage.dart';

class CreateWorkspacePage extends StatefulWidget {
  const CreateWorkspacePage({super.key});

  @override
  State<CreateWorkspacePage> createState() => _CreateWorkspacePageState();
}

class _CreateWorkspacePageState extends State<CreateWorkspacePage> {
  final _nameController = TextEditingController();
  final _emailsController = TextEditingController();
  bool _isLoading = false;

  void _createWorkspace() async {
    final name = _nameController.text.trim();
    final emailsText = _emailsController.text.trim();
    final owner = FirebaseAuth.instance.currentUser;

    if (name.isEmpty || owner == null) return;

    setState(() => _isLoading = true);

    try {
      // Tạo workspace mới
      final docRef = await CloudStorage.db.collection('workspaces').doc();
      List<String> members = [owner.uid];

      // Lấy UID từ email nhập vào
      if (emailsText.isNotEmpty) {
        final emails = emailsText.split(',').map((e) => e.trim()).toList();
        final snapshot = await CloudStorage.db
            .collection('users')
            .where('email', whereIn: emails)
            .get();
        for (var doc in snapshot.docs) {
          members.add(doc.id);
        }
      }

      await docRef.set({
        'id': docRef.id,
        'name': name,
        'ownerUid': owner.uid,
        'members': members,
        'createdAt': DateTime.now(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Tạo workspace thành công")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo Workspace")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Tên workspace",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailsController,
              decoration: const InputDecoration(
                labelText: "Email thành viên (cách nhau dấu ,)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createWorkspace,
                    child: const Text("Tạo workspace"),
                  ),
          ],
        ),
      ),
    );
  }
}
