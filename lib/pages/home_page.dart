import 'package:flutter/material.dart';
import 'addnote_page.dart';
import '../models/note.dart';
import '../widgets/note_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  void _addNote() async {
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (context) => const AddNotePage()),
    );

    if (newNote != null) {
      setState(() {
        notes.add(newNote);
      });
    }
  }

  void _editNote(int index) async {
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (context) => AddNotePage(note: notes[index])),
    );

    if (updatedNote != null) {
      setState(() {
        notes[index] = updatedNote;
      });
    }
  }

  void _deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
  }

  void _showNoteMenu(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E2E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text("Sửa", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _editNote(index);
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
                _deleteNote(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Ghi chú của tôi",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return NoteItem(
                    note: note,
                    onTap: () => _showNoteMenu(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: const Color(0xFF2E2E2E),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
