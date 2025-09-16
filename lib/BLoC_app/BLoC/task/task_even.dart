import 'package:note_clone/core/models/task.dart';

abstract class TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;
  AddTask(this.task);
}

class DeleteTask extends TaskEvent {
  final String id;
  DeleteTask(this.id);
}

class ToggleTask extends TaskEvent {
  final Task task;
  ToggleTask(this.task);
}
