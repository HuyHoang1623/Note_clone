import "dart:convert";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note_clone/core/models/note.dart';

class LocalStorage {
  static const String notePrefix = 'note_';

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
}
