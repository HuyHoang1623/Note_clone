import 'package:note_clone/core/models/task.dart';

abstract class TaskEvent {}

class LoadTasks extends TaskEvent {
  final String uid;
  LoadTasks(this.uid);
}

class AddTask extends TaskEvent {
  final Task task;
  final String uid;
  AddTask(this.task, this.uid);
}

class DeleteTask extends TaskEvent {
  final String id;
  final String uid;
  DeleteTask(this.id, this.uid);
}

class ToggleTask extends TaskEvent {
  final Task task;
  final String uid;
  ToggleTask(this.task, this.uid);
}

class LoadWorkspaceTasks extends TaskEvent {
  final String workspaceId;
  LoadWorkspaceTasks(this.workspaceId);
}

class AddWorkspaceTask extends TaskEvent {
  final String workspaceId;
  final Task task;
  AddWorkspaceTask(this.workspaceId, this.task);
}

class DeleteWorkspaceTask extends TaskEvent {
  final String workspaceId;
  final String taskId;
  DeleteWorkspaceTask(this.workspaceId, this.taskId);
}

class ToggleWorkspaceTask extends TaskEvent {
  final String workspaceId;
  final Task task;
  ToggleWorkspaceTask(this.workspaceId, this.task);
}
