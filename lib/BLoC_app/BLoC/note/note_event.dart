import 'package:note_clone/core/models/note.dart';

abstract class NoteEvent {}

class LoadNotes extends NoteEvent {}

class AddNote extends NoteEvent {
  final Note note;
  AddNote(this.note);
}

class UpdateNote extends NoteEvent {
  final Note note;
  UpdateNote(this.note);
}

class DeleteNote extends NoteEvent {
  final String id;
  DeleteNote(this.id);
}

class SearchNotes extends NoteEvent {
  final String query;
  SearchNotes(this.query);
}
