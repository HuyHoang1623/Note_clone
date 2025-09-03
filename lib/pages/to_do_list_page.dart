import 'package:flutter/material.dart';
import 'home_page.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final List<String> ongoingTasks = [];
  final List<String> completedTasks = [];
  final TextEditingController taskController = TextEditingController();

  void addTask() {
    final task = taskController.text.trim();
    if (task.isNotEmpty) {
      setState(() {
        ongoingTasks.add(task);
        taskController.clear();
      });
    }
  }

  void deleteTask(String task, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        completedTasks.remove(task);
      } else {
        ongoingTasks.remove(task);
      }
    });
  }

  void toggleTask(String task, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        completedTasks.remove(task);
        ongoingTasks.add(task);
      } else {
        ongoingTasks.remove(task);
        completedTasks.add(task);
      }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Việc cần làm"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
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
                        onChanged: (_) => toggleTask(task, false),
                      ),
                      title: Text(task),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(task, false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text("Đã hoàn thành", style: theme.textTheme.titleLarge),
                  ...completedTasks.map(
                    (task) => ListTile(
                      leading: Checkbox(
                        value: true,
                        onChanged: (_) => toggleTask(task, true),
                      ),
                      title: Text(
                        task,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(task, true),
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
