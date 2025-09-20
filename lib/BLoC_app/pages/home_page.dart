import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_even.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_state.dart';
import 'package:note_clone/core/models/note.dart';
import 'package:note_clone/BLoC_app/pages/add_note_page.dart';
import 'package:note_clone/BLoC_app/pages/to_do_list_page.dart';

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

  Widget _buildNoteItem(BuildContext context, Note note) {
    return Card(
      color: note.backgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showNoteMenu(context, note),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: note.textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                note.content,
                style: TextStyle(color: note.textColor),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "${note.date.day}/${note.date.month}/${note.date.year}",
                  style: TextStyle(
                    color: note.textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Ghi chú của tôi"), actions: [
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Tìm kiếm ghi chú...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) =>
                  context.read<NoteBloc>().add(SearchNotes(query)),
            ),
          ),
          Expanded(
            child: BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if (state.filteredNotes.isEmpty) {
                  return Center(
                    child: Text(
                      "Không tìm thấy ghi chú nào",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: state.filteredNotes.length,
                  itemBuilder: (_, i) =>
                      _buildNoteItem(context, state.filteredNotes[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddNote(context),
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 28),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.checklist, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ToDoListPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
