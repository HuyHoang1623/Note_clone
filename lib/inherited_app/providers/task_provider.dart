import 'package:flutter/material.dart';
import 'package:note_clone/core/models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get ongoing =>
      _tasks.where((t) => t.status == TaskStatus.ongoing).toList();
  List<Task> get completed =>
      _tasks.where((t) => t.status == TaskStatus.completed).toList();

  void add(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggle(Task task) {
    task.status = task.status == TaskStatus.ongoing
        ? TaskStatus.completed
        : TaskStatus.ongoing;
    notifyListeners();
  }

  void delete(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
