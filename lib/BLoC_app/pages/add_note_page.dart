import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_event.dart';
import 'package:note_clone/BLoC_app/BLoC/note/note_state.dart';
import 'package:note_clone/core/color_pair.dart';
import 'package:note_clone/core/models/note.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
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
    final controller = VideoPlayerController.file(File(path));
    _videoControllers[path] = controller;
    controller.initialize();
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

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập để lưu ghi chú")),
      );
      return;
    }

    final uid = user.uid;

    final newNote = Note(
      id: widget.note?.id ?? UniqueKey().toString(),
      uid: uid,
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
      bloc.add(AddNote(newNote, uid));
    } else {
      bloc.add(UpdateNote(newNote, uid));
    }
    Navigator.pop(context);
  }

  InputDecoration fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: selectedTextColor),
      filled: true,
      fillColor: selectedBackgroundColor,
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
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.note == null ? "Thêm Ghi Chú" : "Sửa Ghi Chú"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
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
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: widget.noteColors.map((pair) {
                    final background = pair["background"]!;
                    final txt = pair["text"]!;
                    final isSelected =
                        (background == selectedBackgroundColor &&
                        txt == selectedTextColor);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBackgroundColor = background;
                          selectedTextColor = txt;
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: background,
                        radius: 20,
                        child: isSelected
                            ? Icon(Icons.check, color: txt)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (_images.isNotEmpty) ...[
                  const Text(
                    "Ảnh:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _images.map((path) {
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  Dialog(child: Image.file(File(path))),
                            );
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Image.file(
                                  File(path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _images.remove(path);
                                    });
                                  },
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_videos.isNotEmpty) ...[
                  const Text(
                    "Video:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _videos.map((path) {
                        final controller = _videoControllers[path];
                        if (controller == null) {
                          return const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.videocam,
                              size: 48,
                              color: Colors.blue,
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () => _showFullVideo(controller),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: AspectRatio(
                                    aspectRatio: controller.value.aspectRatio,
                                    child: VideoPlayer(controller),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      controller.pause();
                                      _videos.remove(path);
                                      _videoControllers.remove(path)?.dispose();
                                    });
                                  },
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image, size: 32),
                      onPressed: () => _pickImage(fromCamera: false),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, size: 32),
                      onPressed: () => _pickImage(fromCamera: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam, size: 32),
                      onPressed: () => _pickVideo(fromCamera: false),
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam_outlined, size: 32),
                      onPressed: () => _pickVideo(fromCamera: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: selectedBackgroundColor,
            foregroundColor: selectedTextColor,
            onPressed: () => saveNote(context),
            child: const Icon(Icons.save, size: 28),
          ),
        );
      },
    );
  }
}
