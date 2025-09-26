import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_event.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_state.dart';
import 'package:note_clone/core/local_storage.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(const NoteState()) {
    on<LoadNotes>((event, emit) async {
      final notes = await LocalStorage.loadNotes();
      emit(state.copyWith(notes: notes, filteredNotes: notes));
    });

    on<AddNote>((event, emit) async {
      final updated = [...state.notes, event.note];
      emit(state.copyWith(notes: updated, filteredNotes: updated));
      await LocalStorage.saveNote(event.note);
    });

    on<UpdateNote>((event, emit) async {
      final updated = state.notes
          .map((n) => n.id == event.note.id ? event.note : n)
          .toList();
      emit(state.copyWith(notes: updated, filteredNotes: updated));
      await LocalStorage.saveNote(event.note);
    });

    on<DeleteNote>((event, emit) async {
      final updated = state.notes.where((n) => n.id != event.id).toList();
      emit(state.copyWith(notes: updated, filteredNotes: updated));
      await LocalStorage.deleteNote(event.id);
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
