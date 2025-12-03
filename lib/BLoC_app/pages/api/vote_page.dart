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

