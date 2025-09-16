import 'package:note_clone/core/models/note.dart';

class NoteState {
  final List<Note> notes;
  final List<Note> filteredNotes;

  const NoteState({this.notes = const [], this.filteredNotes = const []});

  NoteState copyWith({List<Note>? notes, List<Note>? filteredNotes}) {
    return NoteState(
      notes: notes ?? this.notes,
      filteredNotes: filteredNotes ?? this.filteredNotes,
    );
  }
}
