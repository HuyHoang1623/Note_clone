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
  final ScrollController _scrollController = ScrollController();

  List<Cat> images = [];
  bool isLoading = false;
  bool isLoadMore = false;

  int page = 0;
  final int limit = 20;
  bool hasMore = true;

  bool _lock = false;

  @override
  void initState() {
    super.initState();
    loadImages();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_lock &&
          hasMore) {
        loadMore();
      }
    });
  }

  Future<void> loadImages() async {
    page = 0;
    hasMore = true;
    images.clear();

    setState(() => isLoading = true);
    final data = await _service.fetchCatsPaginated(page: page, limit: limit);

    setState(() {
      images = data;
      isLoading = false;
      if (data.isEmpty) hasMore = false;
    });
  }

  Future<void> loadMore() async {
    if (_lock) return;
    _lock = true;
    isLoadMore = true;
    setState(() {});

    page++;

    final data = await _service.fetchCatsPaginated(page: page, limit: limit);

    if (data.isEmpty) {
      hasMore = false;
    } else {
      final uniqueData = data.where(
        (cat) => !images.any((c) => c.id == cat.id),
      );

      images.addAll(uniqueData);
    }

    isLoadMore = false;
    _lock = false;
    setState(() {});
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
