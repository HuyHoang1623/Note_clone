import 'package:flutter/material.dart';
import 'home_page.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final List<String> todo = [];
  final TextEditingController taskController = TextEditingController();

  void addTask() {
    final task = taskController.text.trim();
    if (task.isNotEmpty) {
      setState(() {
        todo.add(task);
        taskController.clear();
      });
    }
  }

  void deleteTask(int index) {
    setState(() {
      todo.removeAt(index);
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
