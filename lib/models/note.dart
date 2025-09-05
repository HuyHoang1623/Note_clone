class Note {
  String title;
  String content;
  DateTime date;
  String id = DateTime.now().microsecondsSinceEpoch.toString();

  Note({required this.title, required this.content, required this.date});
}
