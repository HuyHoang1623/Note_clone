import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_event.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_state.dart';
import 'package:note_clone/core/models/task.dart';
import 'package:note_clone/core/cloud_storage.dart';
import 'package:note_clone/BLoC_app/pages/home_page.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController taskController = TextEditingController();
  late TabController _tabController;

  List<Map<String, dynamic>> workspaces = [];
  String? selectedWorkspaceId;
  String? selectedWorkspaceName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<TaskBloc>().add(LoadTasks(user.uid));
      _loadWorkspaces(user.uid);
    }
  }

  Future<void> _loadWorkspaces(String uid) async {
    final data = await CloudStorage.getUserWorkspaces(uid);
    setState(() => workspaces = data);
  }

  void addPersonalTask() {
    final title = taskController.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (title.isNotEmpty && user != null) {
      final task = Task(uid: user.uid, title: title, createdAt: DateTime.now());
      context.read<TaskBloc>().add(AddTask(task, user.uid));
      taskController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void addWorkspaceTask() {
    final title = taskController.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (title.isNotEmpty && user != null && selectedWorkspaceId != null) {
      final task = Task(uid: user.uid, title: title, createdAt: DateTime.now());
      context.read<TaskBloc>().add(
        AddWorkspaceTask(selectedWorkspaceId!, task),
      );
      taskController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showCreateWorkspaceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailsController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Tạo Workspace"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Tên workspace",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailsController,
                    decoration: const InputDecoration(
                      labelText: "Email thành viên (phân cách bằng dấu ,)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final emailsText = emailsController.text.trim();
                          final owner = FirebaseAuth.instance.currentUser;
                          if (name.isEmpty || owner == null) return;

                          setState(() => isLoading = true);
                          try {
                            final docRef = CloudStorage.db
                                .collection('workspaces')
                                .doc();
                            List<String> members = [owner.uid];

                            if (emailsText.isNotEmpty) {
                              final emails = emailsText
                                  .split(',')
                                  .map((e) => e.trim())
                                  .toList();
                              final snapshot = await CloudStorage.db
                                  .collection('users')
                                  .where('email', whereIn: emails)
                                  .get();
                              for (var doc in snapshot.docs) {
                                members.add(doc.id);
                              }
                              if (snapshot.docs.length != emails.length) {
                                final foundEmails = snapshot.docs
                                    .map((d) => d['email'] as String)
                                    .toSet();
                                final missing = emails
                                    .where((e) => !foundEmails.contains(e))
                                    .join(', ');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Một số email không tồn tại: $missing",
                                    ),
                                  ),
                                );
                              }
                            }

                            await docRef.set({
                              'id': docRef.id,
                              'name': name,
                              'ownerUid': owner.uid,
                              'members': members,
                              'createdAt': DateTime.now(),
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Tạo workspace thành công!"),
                              ),
                            );

                            Navigator.pop(context);
                            _loadWorkspaces(owner.uid);
                          } catch (e) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                          }
                          setState(() => isLoading = false);
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Tạo"),
                ),
              ],
            );
          },
        );
      },
    );
  }
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.checklist, size: 28),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
