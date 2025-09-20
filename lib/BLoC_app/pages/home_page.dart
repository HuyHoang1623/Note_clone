class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openAddNote(BuildContext context, [Note? note]) async {
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => AddNotePage(note: note)),
    );

    if (newNote != null) {
      if (note == null) {
        context.read<NoteBloc>().add(AddNote(newNote));
      } else {
        context.read<NoteBloc>().add(UpdateNote(newNote));
      }
    }
  }
