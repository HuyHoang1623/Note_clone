import 'package:flutter/material.dart';
import 'package:note_clone/core/models/note.dart';

class NoteProvider extends InheritedWidget {
  final NoteProviderState data;

  const NoteProvider({super.key, required this.data, required Widget child})
    : super(child: child);

  static NoteProviderState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NoteProvider>()!.data;
  }

  @override
  bool updateShouldNotify(NoteProvider oldWidget) => true;
}

class NoteProviderState extends State<StatefulWidget> {
  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  void addNote(Note note) {
    setState(() {
      _notes.add(note);
    });
  }

  void deleteNote(String id) {
    setState(() {
      _notes.removeWhere((n) => n.id == id);
    });
  }

  void editNote(Note updatedNote) {
    setState(() {
      final index = _notes.indexWhere((n) => n.id == updatedNote.id);
      if (index != -1) {
        _notes[index] = updatedNote;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NoteProvider(data: this, child: Container());
  }
}
