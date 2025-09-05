enum TaskStatus { ongoing, completed }

class Task {
  String id = DateTime.now().microsecondsSinceEpoch.toString();
  String title;
  DateTime createdAt;
  TaskStatus status;

  Task({
    required this.title,
    required this.createdAt,
    this.status = TaskStatus.ongoing,
  });
}
