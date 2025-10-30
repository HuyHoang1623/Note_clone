import 'package:note_clone/core/models/task.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> personalTasks;
  final List<Task> workspaceTasks;
  final String? workspaceId;

  TaskLoaded({
    required this.personalTasks,
    this.workspaceTasks = const [],
    this.workspaceId,
  });

  TaskLoaded copyWith({
    List<Task>? personalTasks,
    List<Task>? workspaceTasks,
    String? workspaceId,
  }) {
    return TaskLoaded(
      personalTasks: personalTasks ?? this.personalTasks,
      workspaceTasks: workspaceTasks ?? this.workspaceTasks,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}
