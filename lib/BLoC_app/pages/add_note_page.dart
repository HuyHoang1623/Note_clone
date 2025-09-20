class AddNotePage extends StatefulWidget {
  final Note? note;
  final List<Map<String, Color>> noteColors = ColorPair().colorpairs;

  AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late final TextEditingController titleController;
  late final TextEditingController contentController;
  late Color selectedBackgroundColor;
  late Color selectedTextColor;
