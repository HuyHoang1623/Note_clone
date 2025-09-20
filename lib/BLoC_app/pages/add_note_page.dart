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
  final _picker = ImagePicker();

  List<String> _images = [];
  List<String> _videos = [];
  final Map<String, VideoPlayerController> _videoControllers = {};
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');

    selectedBackgroundColor = widget.note?.backgroundColor ?? Colors.white;
    selectedTextColor = widget.note?.textColor ?? Colors.black87;

    _images = List.from(widget.note?.imagePaths ?? []);
    _videos = List.from(widget.note?.videoPaths ?? []);

    for (var path in _videos) {
      _initVideoController(path);
    }
  }
  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  Future<void> _pickImage({bool fromCamera = false}) async {
    final picked = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (picked != null) {
      setState(() => _images.add(picked.path));
    }
  }

  Future<void> _pickVideo({bool fromCamera = false}) async {
    final picked = await _picker.pickVideo(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (picked != null) {
      setState(() {
        _videos.add(picked.path);
        _initVideoController(picked.path);
      });
    }
  }

  void _initVideoController(String path) {
    final controller = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        setState(() {});
      });
    _videoControllers[path] = controller;
  }
