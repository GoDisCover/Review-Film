import 'package:flutter/material.dart';
import 'package:review_film/model/film_model.dart';

class FilmCard extends StatelessWidget {
  final Film film;
  const FilmCard({super.key, required this.film});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8),
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

                },
                child: Stack(
                  children: [

                    Image.network(
                      film.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey, child: Icon(Icons.error));
                      },
                    ),
                    

                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Color(0x00000000), Color(0xFF21201e)],
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
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Color(0xffF8F3CE), size: 14),
                                const SizedBox(width: 4),

                                Text(
                                  film.rating.toStringAsFixed(1), 
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
                          const SizedBox(width: 100),
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
                          const SizedBox(height: 4),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 4.0, 
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                            padding: EdgeInsets.zero,
                            itemCount: film.genre.length, 
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7A7A73),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  film.genre[index],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFE0D9C8),
                                    fontSize: 10, 
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
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