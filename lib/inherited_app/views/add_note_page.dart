import 'package:flutter/material.dart';
import '../../core/models/note.dart';
import 'package:note_clone/core/color_pair.dart';
import 'package:note_clone/inherited_app/providers/note_provider.dart';

class AddNotePage extends StatefulWidget {
  final Note? note;
  final List<Map<String, Color>> noteColors = ColorPair().colorpairs;

  AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => AddNotePageState();
}

class AddNotePageState extends State<AddNotePage> {
  late final TextEditingController titleController;
  late final TextEditingController contentController;

  late Color selectedBgColor;
  late Color selectedTextColor;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');

    selectedBgColor = widget.note?.backgroundColor ?? Colors.white;
    selectedTextColor = widget.note?.textColor ?? Colors.black87;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void saveNote() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    final noteProvider = NoteProvider.of(context);

    final newNote = Note(
      id: widget.note?.id ?? UniqueKey().toString(),
      title: title,
      content: content,
      date: DateTime.now(),
      backgroundColor: selectedBgColor,
      textColor: selectedTextColor,
    );

    if (widget.note == null) {
      noteProvider.addNote(newNote); // thêm mới
    } else {
      noteProvider.editNote(newNote); // sửa
    }

    Navigator.pop(context); // chỉ cần quay lại, không cần trả data
  }

  InputDecoration fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: selectedTextColor),
      filled: true,
      fillColor: selectedBgColor,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: selectedTextColor.withOpacity(0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: selectedTextColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? "Thêm Ghi Chú" : "Sửa Ghi Chú"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: selectedTextColor),
              decoration: fieldDecoration("Tiêu đề"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              style: TextStyle(color: selectedTextColor),
              decoration: fieldDecoration("Nội dung"),
              maxLines: 10,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: widget.noteColors.map((pair) {
                final bg = pair["bg"]!;
                final txt = pair["text"]!;
                final isSelected =
                    (bg == selectedBgColor && txt == selectedTextColor);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBgColor = bg;
                      selectedTextColor = txt;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: bg,
                    radius: 20,
                    child: isSelected ? Icon(Icons.check, color: txt) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: selectedBgColor,
        foregroundColor: selectedTextColor,
        onPressed: saveNote,
        child: const Icon(Icons.save, size: 28),
      ),
    );
  }
}
