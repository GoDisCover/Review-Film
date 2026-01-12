import 'package:flutter/material.dart';
import 'package:review_film/model/film_model.dart';
import 'package:review_film/pages/detail_screen.dart';

class FilmCard extends StatelessWidget {
  final Film film;
  final String userEmail;

  const FilmCard({
    super.key,
    required this.film,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    // Logika untuk menangani genre:
    // Jika film.genre adalah String (misal: "Action, Drama"), kita split jadi List.
    // Jika model Anda sudah List<String>, kode ini tetap aman.
    final List<String> genres = film.genre is String
        ? (film.genre as String).split(',')
        : (film.genre as List).map((e) => e.toString()).toList();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(4),
      elevation: 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        film: film,
                        userEmail: userEmail,
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Image.network(
                      film.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey,
                          child: const Center(child: Icon(Icons.error)),
                        );
                      },
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.transparent,
                            Color(0xFF21201e)
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF57564F),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Color(0xffF8F3CE), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  (film.rating ?? 0.0).toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Color(0xffF8F3CE),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            film.namaFilm,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xffF8F3CE),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: genres.take(2).map((genre) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7A7A73),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  genre.trim(),
                                  style: const TextStyle(
                                    color: Color(0xFFE0D9C8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}