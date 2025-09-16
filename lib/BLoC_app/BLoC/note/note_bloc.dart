import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_even.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(const NoteState()) {
    on<LoadNotes>((event, emit) {
      emit(state.copyWith(notes: [], filteredNotes: []));
    });

    on<AddNote>((event, emit) {
      final updated = [...state.notes, event.note];
      emit(state.copyWith(notes: updated, filteredNotes: updated));
    });

    on<UpdateNote>((event, emit) {
      final updated = state.notes
          .map((n) => n.id == event.note.id ? event.note : n)
          .toList();
      emit(state.copyWith(notes: updated, filteredNotes: updated));
    });

    on<DeleteNote>((event, emit) {
      final updated = state.notes.where((n) => n.id != event.id).toList();
      emit(state.copyWith(notes: updated, filteredNotes: updated));
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
