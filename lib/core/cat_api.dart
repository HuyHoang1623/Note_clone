class CatBreed {
  final String id;
  final String name;
  final String? origin;
  final String? temperament;

  CatBreed({
    required this.id,
    required this.name,
    this.origin,
    this.temperament,
  });

  factory CatBreed.fromJson(Map<String, dynamic> json) {
    return CatBreed(
      id: json['id'],
      name: json['name'],
      origin: json['origin'],
      temperament: json['temperament'],
    );
  }
}
