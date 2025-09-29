import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_clone/core/models/note.dart';
import 'package:note_clone/core/models/task.dart';

class CloudStorage {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static Future<void> addNote(Note note) async {
    await db.collection('notes').doc(note.id).set(note.toJson());
  }

  static Future<void> updateNote(Note note) async {
    await db.collection('notes').doc(note.id).update(note.toJson());
  }

  static Future<void> deleteNote(String id) async {
    await db.collection('notes').doc(id).delete();
  }

  static Future<List<Note>> getNotes() async {
    final snapshot = await db.collection('notes').get();
    return snapshot.docs.map((doc) => Note.fromJson(doc.data())).toList();
  }

  static Future<void> addTask(Task task) async {
    await db.collection('tasks').doc(task.id).set(task.toJson());
  }

  static Future<void> updateTask(Task task) async {
    await db.collection('tasks').doc(task.id).update(task.toJson());
  }

  static Future<void> deleteTask(String id) async {
    await db.collection('tasks').doc(id).delete();
  }

  static Future<List<Task>> getTasks() async {
    final snapshot = await db.collection('tasks').get();
    return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
  }
}
