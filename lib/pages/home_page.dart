import 'package:flutter/material.dart';
import 'add_note_page.dart';
import '../models/note.dart';
import '../widgets/note_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<Note> notes = [
    Note(
      title: "Ghi chú 1",
      content: "Nội dung ghi chú 1",
      date: DateTime.now(),
    ),
    Note(
      title: "Ghi chú 2",
      content: "Nội dung ghi chú 2",
      date: DateTime(2025, 5, 20),
    ),
    Note(
      title: "Ghi chú 3",
      content: "Nội dung ghi chú 3",
      date: DateTime(2024, 12, 15),
    ),
  ];

  late List<Note> filteredNotes;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredNotes = notes;
    searchController.addListener(_searchNotes);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _searchNotes() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredNotes = notes.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  void addNote() async {
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (context) => const AddNotePage()),
    );
    if (newNote != null) {
      setState(() {
        notes.add(newNote);
        _searchNotes();
      });
    }
  }

  void editNote(int index) async {
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(note: filteredNotes[index]),
      ),
    );
    if (updatedNote != null) {
      final noteIndex = notes.indexOf(filteredNotes[index]);
      setState(() {
        notes[noteIndex] = updatedNote;
        _searchNotes();
      });
    }
  }

  void deleteNote(int index) {
    final noteIndex = notes.indexOf(filteredNotes[index]);
    setState(() {
      notes.removeAt(noteIndex);
      _searchNotes();
    });
  }

  void showNoteMenu(int index) {
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
                editNote(index);
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
                deleteNote(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ghi chú của tôi"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Tìm kiếm ghi chú...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor:
                    theme.inputDecorationTheme.fillColor ??
                    theme.colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Text(
                      "Không tìm thấy ghi chú nào",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return NoteItem(
                        note: note,
                        onTap: () => showNoteMenu(index),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
