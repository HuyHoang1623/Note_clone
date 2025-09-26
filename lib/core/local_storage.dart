import "dart:convert";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note_clone/core/models/note.dart';
import 'package:note_clone/core/models/task.dart';

class LocalStorage {
  static const String notePrefix = 'note_';
  static const String taskPrefix = 'task_';

  static Future<void> saveNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(noteKey(note.id), jsonEncode(note.toJson()));
  }

  static Future<void> deleteNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(noteKey(id));
  }

  static Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(notePrefix));
    List<Note> notes = [];
    for (var key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        notes.add(Note.fromJson(jsonDecode(jsonStr)));
      }
    }
    notes.sort((a, b) => b.date.compareTo(a.date));
    return notes;
  }

  static String noteKey(String id) => '$notePrefix$id';

  static Future<void> saveTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(taskKey(task.id), jsonEncode(task.toJson()));
  }

  static Future<void> deleteTask(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(taskKey(id));
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(taskPrefix));
    List<Task> tasks = [];
    for (var key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        tasks.add(Task.fromJson(jsonDecode(jsonStr)));
      }
    }
    return tasks;
  }

  static String taskKey(String id) => '$taskPrefix$id';
}
