import 'package:flutter/material.dart';
import 'package:note_clone/core/models/note.dart';

class NoteProvider extends ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => List.unmodifiable(_notes);

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  void deleteNoteById(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}
