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
                    decoration: const InputDecoration(
                      hintText: "Nhập việc cần làm...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                              }
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
