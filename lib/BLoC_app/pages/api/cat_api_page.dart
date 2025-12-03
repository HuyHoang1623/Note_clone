import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'cat_model.dart';
import 'cat_api_service.dart';
import 'vote_page.dart';

class CatPage extends StatefulWidget {
  const CatPage({super.key});

  @override
  State<CatPage> createState() => CatPageState();
}

class CatPageState extends State<CatPage> {
  final CatApiService _service = CatApiService();
  List<Cat> images = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    final data = await _service.fetchImages();
    setState(() => images = data);
  }

  Future<void> pickAndUpload() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => isLoading = true);

    final uploaded = await _service.uploadImage(File(file.path));

    if (uploaded == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đây không phải ảnh mèo, vui lòng chọn ảnh khác"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    images.insert(0, uploaded);
    setState(() => isLoading = false);
  }

  Future<void> deleteImage(Cat cat) async {
    await _service.deleteImage(cat.id);
    images.remove(cat);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cat Images"),
        actions: [
          IconButton(
            icon: const Icon(Icons.how_to_vote),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VotePage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : pickAndUpload,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),
      body: images.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: images.length,
              itemBuilder: (_, index) {
                final cat = images[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Image.network(cat.url),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteImage(cat),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
