import 'package:flutter/material.dart';
import 'package:review_film/model/film_model.dart';
import 'package:review_film/sqlite/database_helper.dart';
import 'package:review_film/widgets/film_card.dart';

class MyReviewPage extends StatefulWidget {
  const MyReviewPage({super.key, this.userEmail});
  final String? userEmail;
  @override
  State<MyReviewPage> createState() => _MyReviewPageState();
}

class _MyReviewPageState extends State<MyReviewPage> {
  late Future<List<Film>> _filmsFuture;
  final dbHelper = DatabaseHelper();
  String _searchKeyword = "";

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
        _filmsFuture = dbHelper.getMyFilms(widget.userEmail!);
      } else {
        _filmsFuture = Future.value([]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffDDDAD0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search Your Anime",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.black54),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchKeyword = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Film>>(
                future: _filmsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("You haven't added any films yet"),
                    );
                  } else {
                    final films = snapshot.data!;
                    final filteredFilms = films.where((film) {
                      return film.namaFilm
                          .toLowerCase()
                          .contains(_searchKeyword.toLowerCase());
                    }).toList();

                    if (filteredFilms.isEmpty) {
                      return const Center(child: Text("Movie not found"));
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        itemCount: filteredFilms.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final Film film = filteredFilms[index];
                          return FilmCard(film: film);
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}