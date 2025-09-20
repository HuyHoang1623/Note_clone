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

  void _showNoteMenu(BuildContext context, Note note) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: theme.colorScheme.primary),
              title: Text(
                "Sửa",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              onTap: () {
                Navigator.pop(context);
                _openAddNote(context, note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                "Xoá",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<NoteBloc>().add(DeleteNote(note.id));
              },
            ),
          ],
        ),
      ),
    );
  }
