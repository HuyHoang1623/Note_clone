enum TaskStatus { ongoing, completed }

class Task {
  final String id;
  final String title;
  final DateTime createdAt;
  final TaskStatus status;

  Task({
    String? id,
    required this.title,
    required this.createdAt,
    this.status = TaskStatus.ongoing,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Task copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'status': status.index,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      status: TaskStatus.values[json['status']],
    );
  }
}
