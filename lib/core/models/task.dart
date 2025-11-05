import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { ongoing, completed }

class Task {
  final String id;
  final String uid;
  final String title;
  final DateTime createdAt;
  final TaskStatus status;
  final String? workspaceId;

  Task({
    String? id,
    required this.uid,
    required this.title,
    required this.createdAt,
    this.status = TaskStatus.ongoing,
    this.workspaceId,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Task copyWith({
    String? id,
    String? uid,
    String? title,
    DateTime? createdAt,
    TaskStatus? status,
    String? workspaceId,
  }) {
    return Task(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'status': status.index,
      'workspaceId': workspaceId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      uid: json['uid'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      status: TaskStatus.values[json['status']],
      workspaceId: json['workspaceId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.index,
      'workspaceId': workspaceId,
    };
  }

  factory Task.fromFirestore(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      uid: json['uid'],
      title: json['title'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      status: TaskStatus.values[json['status']],
      workspaceId: json['workspaceId'],
    );
  }
}
