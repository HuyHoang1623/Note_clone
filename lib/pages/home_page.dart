import 'package:flutter/material.dart';
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
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Note(
      title: "Ghi chú 3",
      content: "Nội dung ghi chú 3",
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  void _addNote() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh trên cùng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.add), onPressed: _addNote),
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
            const SizedBox(height: 8),

            // Danh sách ghi chú
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return NoteItem(note: note, onTap: () {});
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
