import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_event.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_state.dart';
import 'package:note_clone/BLoC_app/pages/home_page.dart';
import 'package:note_clone/core/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ToDoListPage extends StatelessWidget {
  const ToDoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = TextEditingController();
    final theme = Theme.of(context);

    void addTask() {
      final title = taskController.text.trim();
      final user = FirebaseAuth.instance.currentUser;
      if (title.isNotEmpty && user != null) {
        final task = Task(
          uid: user.uid,
          title: title,
          createdAt: DateTime.now(),
          id: DateTime.now().microsecondsSinceEpoch.toString(),
        );
        context.read<TaskBloc>().add(AddTask(task, user.uid));
        taskController.clear();
        FocusScope.of(context).unfocus();
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Việc cần làm")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      hintText: "Nhập việc cần làm...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: addTask, child: const Text("Thêm")),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state.tasks.isEmpty) {
                    return const Center(
                      child: Text("Chưa có việc nào, hãy thêm mới nhé!"),
                    );
                  }

                  final ongoing = state.tasks
                      .where((t) => t.status == TaskStatus.ongoing)
                      .toList();
                  final completed = state.tasks
                      .where((t) => t.status == TaskStatus.completed)
                      .toList();

                  return ListView(
                    children: [
                      Text(
                        "Chưa hoàn thành",
                        style: theme.textTheme.titleLarge,
                      ),
                      ...ongoing.map(
                        (task) => ListTile(
                          leading: Checkbox(
                            value: false,
                            onChanged: (_) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                context.read<TaskBloc>().add(
                                  ToggleTask(task, user.uid),
                                );
                              }
                            },
                          ),
                          title: Text(task.title),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                context.read<TaskBloc>().add(
                                  DeleteTask(task.id, user.uid),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      const Divider(height: 30, thickness: 1),
                      Text("Đã hoàn thành", style: theme.textTheme.titleLarge),
                      ...completed.map(
                        (task) => ListTile(
                          leading: Checkbox(
                            value: true,
                            onChanged: (_) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                context.read<TaskBloc>().add(
                                  ToggleTask(task, user.uid),
                                );
                              }
                            },
                          ),
                          title: Text(
                            task.title,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                context.read<TaskBloc>().add(
                                  DeleteTask(task.id, user.uid),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
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
