import 'package:flutter/material.dart';
import 'package:note_clone/core/models/task.dart';

class TaskProvider extends InheritedWidget {
  final TaskProviderState data;

  const TaskProvider({super.key, required this.data, required Widget child})
    : super(child: child);

  static TaskProviderState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TaskProvider>()!.data;
  }

  @override
  bool updateShouldNotify(TaskProvider oldWidget) => true;
}

class TaskProviderState extends State<StatefulWidget> {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
  }

  void deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
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
  Widget build(BuildContext context) {
    return TaskProvider(data: this, child: Container());
  }
}
