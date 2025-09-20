import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_even.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_state.dart';
import 'package:note_clone/BLoC_app/pages/home_page.dart';
import 'package:note_clone/core/models/task.dart';

class ToDoListPage extends StatelessWidget {
  const ToDoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = TextEditingController();
    final theme = Theme.of(context);

    void addTask() {
      final title = taskController.text.trim();
      if (title.isNotEmpty) {
        final task = Task(title: title, createdAt: DateTime.now());
        context.read<TaskBloc>().add(AddTask(task));
        taskController.clear();
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
                      hintText: "Việc cần làm",
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
                            onChanged: (_) =>
                                context.read<TaskBloc>().add(ToggleTask(task)),
                          ),
                          title: Text(task.title),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => context.read<TaskBloc>().add(
                              DeleteTask(task.id),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text("Đã hoàn thành", style: theme.textTheme.titleLarge),
                      ...completed.map(
                        (task) => ListTile(
                          leading: Checkbox(
                            value: true,
                            onChanged: (_) =>
                                context.read<TaskBloc>().add(ToggleTask(task)),
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
                            onPressed: () => context.read<TaskBloc>().add(
                              DeleteTask(task.id),
                            ),
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
