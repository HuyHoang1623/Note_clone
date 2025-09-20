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
  void _showFullVideo(VideoPlayerController controller) {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.black,
              insetPadding: EdgeInsets.zero,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                  IconButton(
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      color: Colors.white,
                      size: 60,
                    ),
                    onPressed: () {
                      setStateDialog(() {
                        controller.value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      });
                    },
                  ),
                  Positioned(
                    top: 30,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 32,
                      ),
                      onPressed: () {
                        controller.pause();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void saveNote(BuildContext context) {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    final newNote = Note(
      id: widget.note?.id ?? UniqueKey().toString(),
      title: title,
      content: content,
      date: DateTime.now(),
      backgroundColor: selectedBackgroundColor,
      textColor: selectedTextColor,
      imagePaths: _images,
      videoPaths: _videos,
    );

    final bloc = context.read<NoteBloc>();
    if (widget.note == null) {
      bloc.add(AddNote(newNote));
    } else {
      bloc.add(UpdateNote(newNote));
    }
    Navigator.pop(context);
  }

