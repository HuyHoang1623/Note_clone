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

