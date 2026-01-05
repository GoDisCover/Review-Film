import 'package:flutter/material.dart';
import 'package:review_film/model/film_model.dart';
import 'package:review_film/sqlite/database_helper.dart'; // Import Database
import 'package:review_film/widgets/film_card.dart';

class MyReviewPage extends StatefulWidget {
  const MyReviewPage({super.key, this.userEmail});
  final String? userEmail;
  @override
  State<MyReviewPage> createState() => _MyReviewPageState();
}

class _MyReviewPageState extends State<MyReviewPage> {
  // Variable untuk menampung Future data film
  late Future<List<Film>> _filmsFuture;
  final dbHelper = DatabaseHelper();

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
      backgroundColor: const Color(0xffDDDAD0), // Warna background krem
      body: SafeArea(
        child: Column(
          children: [
            // --- BAGIAN 1: SEARCH BAR (Sesuai Desain) ---
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
                    // Nanti bisa tambahkan logika pencarian disini
                  },
                ),
              ),
            ),

            // --- BAGIAN 2: LIST FILM DARI DATABASE ---
            Expanded(
              child: FutureBuilder<List<Film>>(
                future: _filmsFuture, // Variable future di atas
                builder: (context, snapshot) {
                  // 1. Jika sedang loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // 2. Jika ada Error
                  else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  // 3. Jika Data Kosong
                  else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No films found in database"),
                    );
                  }
                  // 4. Jika Data Ada -> Tampilkan Grid
                  else {
                    final films = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        itemCount: films.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 Kolom
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio:
                                  0.65, // Sesuaikan rasio agar kartu tidak gepeng
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          final Film film = films[index];
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
