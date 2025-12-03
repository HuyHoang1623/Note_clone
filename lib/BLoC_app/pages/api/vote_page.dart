import 'package:flutter/material.dart';
import 'cat_api_service.dart';
import 'cat_model.dart';

class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  final CatApiService _service = CatApiService();

  List<Cat> images = [];
  List<Map<String, dynamic>> votes = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    setState(() => isLoading = true);
    images = await _service.fetchImages();
    votes = await _service.getAllVotes();
    setState(() => isLoading = false);
  }

  Map<String, dynamic>? getVote(String imageId) {
    try {
      return votes.firstWhere((v) => v["image_id"] == imageId);
    } catch (e) {
      return null;
    }
  }

  int countLikes(String imageId) {
    return votes
        .where((v) => v["image_id"] == imageId && v["value"] == 1)
        .length;
  }

  int countDislikes(String imageId) {
    return votes
        .where((v) => v["image_id"] == imageId && v["value"] == 0)
        .length;
  }

  Future<void> toggleLike(String imageId) async {
    final vote = getVote(imageId);

    if (vote == null) {
      await _service.voteImage(imageId, 1);
    } else if (vote["value"] == 1) {
      await _service.deleteVote(vote["id"]);
    } else {
      await _service.deleteVote(vote["id"]);
      await _service.voteImage(imageId, 1);
    }

    votes = await _service.getAllVotes();
    setState(() {});
  }

  Future<void> toggleDislike(String imageId) async {
    final vote = getVote(imageId);

    if (vote == null) {
      await _service.voteImage(imageId, 0);
    } else if (vote["value"] == 0) {
      await _service.deleteVote(vote["id"]);
    } else {
      await _service.deleteVote(vote["id"]);
      await _service.voteImage(imageId, 0);
    }

    votes = await _service.getAllVotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vote Cats")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: images.length,
              itemBuilder: (_, index) {
                final cat = images[index];
                final imageId = cat.id;
                final vote = getVote(imageId);
                final value = vote?["value"];

                final likeCount = countLikes(imageId);
                final dislikeCount = countDislikes(imageId);

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Image.network(cat.url),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.thumb_up,
                                  color: value == 1 ? Colors.blue : Colors.grey,
                                ),
                                onPressed: () => toggleLike(imageId),
                              ),
                              Text("$likeCount"),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.thumb_down,
                                  color: value == 0 ? Colors.red : Colors.grey,
                                ),
                                onPressed: () => toggleDislike(imageId),
                              ),
                              Text("$dislikeCount"),
                            ],
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
