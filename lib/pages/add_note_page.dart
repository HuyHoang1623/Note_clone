import 'package:flutter/material.dart';
import '../models/note.dart';

class AddNotePage extends StatefulWidget {
  final Note? note;
  const AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => AddNotePageState();
}

class AddNotePageState extends State<AddNotePage> {
  late final TextEditingController titleController;
  late final TextEditingController contentController;

  late Color selectedBgColor;
  late Color selectedTextColor;

  final List<Map<String, Color>> noteColors = [
    {"bg": const Color(0xFFF98866), "text": const Color(0xFFFFF2D7)},
    {"bg": const Color(0xFF203FFF), "text": const Color(0xFFADEFD1)},
    {"bg": const Color(0xFFF95700), "text": const Color(0xFFFFFFFF)},
    {"bg": const Color(0xFF6F56A6), "text": const Color(0xFFF1E5FF)},
    {"bg": const Color(0xFF2C5F2D), "text": const Color(0xFFFFDD4A)},
    {"bg": const Color(0xFF0D706E), "text": const Color(0xFFCEEFFA)},
    {"bg": const Color(0xFF00539C), "text": const Color(0xFFFFB58F)},
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');

    selectedBgColor = widget.note?.bgColor ?? Colors.white;
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

    Navigator.pop(
      context,
      Note(
        id: widget.note?.id,
        title: title,
        content: content,
        date: DateTime.now(),
        bgColor: selectedBgColor,
        textColor: selectedTextColor,
      ),
    );
  }

  InputDecoration fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: selectedTextColor),
      filled: true,
      fillColor: selectedBgColor, // 🔹 nền bên trong TextField
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
              children: noteColors.map((pair) {
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
