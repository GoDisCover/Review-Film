class Film {
  int? id;
  final String namaFilm;
  final String description;
  final String imageUrl;
  final List<String> genre;
  final double rating;

  Film({
    this.id,
    required this.namaFilm,
    required this.description,
    required this.imageUrl,
    required this.genre,
    this.rating = 0.0,
  });

  factory Film.fromMap(Map<String, dynamic> map) {
    return Film(
      id: map['id'],
      namaFilm: map['nama_film'],
      description: map['description'],
      imageUrl: map['image_url'],
      genre: (map['genre'] as String).split(','),
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : 0.0,
    );
  }

  // ToMap (DARI APLIKASI KE DB)
  Map<String, dynamic> toMap() {
    return {
      'nama_film': namaFilm,
      'description': description,
      'image_url': imageUrl,
      'genre': genre.join(','),
    };
  }
}
