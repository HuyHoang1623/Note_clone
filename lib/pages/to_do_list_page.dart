import 'package:flutter/material.dart';
import 'home_page.dart';
import '../models/task.dart';
import '../main.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final List<Task> tasks = [];
  final TextEditingController taskController = TextEditingController();

  void addTask() {
    final taskTitle = taskController.text.trim();
    if (taskTitle.isNotEmpty) {
      setState(() {
        tasks.add(Task(title: taskTitle, createdAt: DateTime.now()));
        taskController.clear();
      });
    }
  }

  void deleteTask(String id) {
    setState(() {
      tasks.removeWhere((task) => task.id == id);
    });
  }

  void toggleTask(Task task) {
    setState(() {
      task.status = task.status == TaskStatus.ongoing
          ? TaskStatus.completed
          : TaskStatus.ongoing;
    });
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ongoingTasks = tasks
        .where((task) => task.status == TaskStatus.ongoing)
        .toList();
    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.completed)
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
              const PopupMenuItem(value: "system", child: Text("System Theme")),
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
                ElevatedButton(onPressed: addTask, child: const Text("Thêm")),
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
                        onChanged: (_) => toggleTask(task),
                      ),
                      title: Text(task.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(task.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Đã hoàn thành", style: theme.textTheme.titleLarge),
                  ...completedTasks.map(
                    (task) => ListTile(
                      leading: Checkbox(
                        value: true,
                        onChanged: (_) => toggleTask(task),
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
                        onPressed: () => deleteTask(task.id),
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
