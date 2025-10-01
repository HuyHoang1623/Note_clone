import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_event.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_state.dart';
import 'package:note_clone/core/local_storage.dart';
import 'package:note_clone/core/cloud_storage.dart';
import 'package:note_clone/core/models/note.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(const NoteState()) {
    on<LoadNotes>((event, emit) async {
      List<Note> notes = [];
      try {
        notes = await CloudStorage.getNotes();
        for (var n in notes) {
          await LocalStorage.saveNote(n);
        }
      } catch (e) {
        final localNotes = await LocalStorage.loadNotes();
        notes = localNotes
            .map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      emit(state.copyWith(notes: notes, filteredNotes: notes));
    });

    on<AddNote>((event, emit) async {
      final updated = [...state.notes, event.note];
      emit(state.copyWith(notes: updated, filteredNotes: updated));

      await LocalStorage.saveNote(event.note);
      try {
        await CloudStorage.addNote(event.note);
      } catch (_) {}
    });

    /// UPDATE NOTE
    on<UpdateNote>((event, emit) async {
      final updated = state.notes
          .map((n) => n.id == event.note.id ? event.note : n)
          .toList();
      emit(state.copyWith(notes: updated, filteredNotes: updated));

      await LocalStorage.saveNote(event.note);
      try {
        await CloudStorage.addNote(event.note);
      } catch (_) {}
    });

    on<DeleteNote>((event, emit) async {
      final updated = state.notes.where((n) => n.id != event.id).toList();
      emit(state.copyWith(notes: updated, filteredNotes: updated));

      await LocalStorage.deleteNote(event.id);
      try {
        await CloudStorage.deleteNote(event.id);
      } catch (_) {}
    });

    on<SearchNotes>((event, emit) {
      final filtered = state.notes
          .where(
            (n) =>
                n.title.toLowerCase().contains(event.query.toLowerCase()) ||
                n.content.toLowerCase().contains(event.query.toLowerCase()),
          )
          .toList();
      emit(state.copyWith(filteredNotes: filtered));
    });
  }
}
