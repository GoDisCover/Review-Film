class Review {
  int? id;
  final String userEmail;
  final int filmId;
  final double rating;


  Review({
    this.id,
    required this.userEmail,
    required this.filmId,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_email': userEmail,
      'film_id': filmId,
      'rating': rating,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      userEmail: map['user_email'],
      filmId: map['film_id'],
      rating: map['rating'],
    );
  }
}