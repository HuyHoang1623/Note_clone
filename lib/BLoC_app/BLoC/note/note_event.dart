import 'package:note_clone/core/models/note.dart';

abstract class NoteEvent {}

class LoadNotes extends NoteEvent {
  final String uid;
  LoadNotes(this.uid);
}

class AddNote extends NoteEvent {
  final Note note;
  final String uid;
  AddNote(this.note, this.uid);
}

class UpdateNote extends NoteEvent {
  final Note note;
  final String uid;
  UpdateNote(this.note, this.uid);
}

class DeleteNote extends NoteEvent {
  final String id;
  final String uid;
  DeleteNote(this.id, this.uid);
}

class SearchNotes extends NoteEvent {
  final String query;
  SearchNotes(this.query);
}

class ClearNotes extends NoteEvent {}
