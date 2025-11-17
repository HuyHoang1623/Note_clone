import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_clone/core/models/note.dart';
import 'package:note_clone/core/models/task.dart';

class CloudStorage {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static Future<void> addNote(Note note, String uid) async {
    await db
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(note.id)
        .set(note.toJson());
  }

  static Future<void> updateNote(Note note, String uid) async {
    await db
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(note.id)
        .set(note.toJson(), SetOptions(merge: true));
  }

  static Future<void> deleteNote(String id, String uid) async {
    await db.collection('users').doc(uid).collection('notes').doc(id).delete();
  }

  static Future<List<Note>> getNotes(String uid) async {
    try {
      final snapshot = await db
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();
      return snapshot.docs.map((doc) => Note.fromJson(doc.data())).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addTask(Task task, String uid) async {
    await db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson());
  }

  static Future<void> updateTask(Task task, String uid) async {
    await db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson(), SetOptions(merge: true));
  }

  static Future<void> deleteTask(String id, String uid) async {
    await db.collection('users').doc(uid).collection('tasks').doc(id).delete();
  }

  static Future<List<Task>> getTasks(String uid) async {
    final snapshot = await db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();
    return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
  }
}
