import 'package:flutter/material.dart';
import 'package:note_clone/core/models/task.dart';
import 'package:note_clone/inherited_app/providers/task_provider.dart';
import 'package:note_clone/main.dart';
import 'package:note_clone/inherited_app/views/home_page.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final TextEditingController taskController = TextEditingController();

  void addTask(TaskProviderState provider) {
    final taskTitle = taskController.text.trim();
    if (taskTitle.isNotEmpty) {
      provider.addTask(Task(title: taskTitle, createdAt: DateTime.now()));
      taskController.clear();
    }
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = TaskProvider.of(context);

    final ongoingTasks = taskProvider.tasks
        .where((t) => t.status == TaskStatus.ongoing)
        .toList();
    final completedTasks = taskProvider.tasks
        .where((t) => t.status == TaskStatus.completed)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Việc cần làm"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) {
              if (value == "light") {
                MyApp.of(context)?.changeTheme(ThemeMode.light);
              } else if (value == "dark") {
                MyApp.of(context)?.changeTheme(ThemeMode.dark);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "light", child: Text("Light Theme")),
              const PopupMenuItem(value: "dark", child: Text("Dark Theme")),
            ],
          ),
        ],
      ),
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
                ElevatedButton(
                  onPressed: () => addTask(taskProvider),
                  child: const Text("Thêm"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  Text("Chưa hoàn thành", style: theme.textTheme.titleLarge),
                  ...ongoingTasks.map(
                    (task) => ListTile(
                      leading: Checkbox(
                        value: false,
                        onChanged: (_) => taskProvider.toggleTask(task),
                      ),
                      title: Text(task.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => taskProvider.deleteTask(task.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Đã hoàn thành", style: theme.textTheme.titleLarge),
                  ...completedTasks.map(
                    (task) => ListTile(
                      leading: Checkbox(
                        value: true,
                        onChanged: (_) => taskProvider.toggleTask(task),
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
                        onPressed: () => taskProvider.deleteTask(task.id),
                      ),
                    ),
                  ),
                ],
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
                  MaterialPageRoute(builder: (context) => const HomePage()),
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
