import 'package:flutter/material.dart';
import 'package:review_film/model/film_model.dart';
import 'package:review_film/sqlite/database_helper.dart';
import 'package:review_film/widgets/film_card.dart';

class SearchPage extends StatefulWidget {
  // 1. Tambahkan variable userEmail
  final String? userEmail;

  // 2. Tambahkan ke constructor
  const SearchPage({super.key, this.userEmail});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Film> _allFilms = [];
  List<Film> _foundFilms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshFilms();
  }

  void _refreshFilms() async {
    final data = await DatabaseHelper().getAllFilms();
    setState(() {
      _allFilms = data;
      _foundFilms = data;
      _isLoading = false;
    });
  }

  void _runFilter(String enteredKeyword) {
    List<Film> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allFilms;
    } else {
      results = _allFilms
          .where((film) =>
          film.namaFilm.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundFilms = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Film'),
        backgroundColor: const Color(0xFF57564F),
      ),
      backgroundColor: const Color(0xFF7A7A73),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color(0xFFDDDAD0),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                onChanged: (value) => _runFilter(value),
                decoration: const InputDecoration(
                  hintText: 'Search movie name...',
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _foundFilms.isEmpty
                ? const Center(
              child: Text(
                'No films found',
                style: TextStyle(color: Colors.white),
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(5),
              child: GridView.builder(
                itemCount: _foundFilms.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final Film film = _foundFilms[index];
                  // 3. Sekarang widget.userEmail sudah valid
                  return FilmCard(
                    film: film,
                    userEmail: widget.userEmail ?? "",
                    onUpdate: () {
                      _refreshFilms(); // Refresh data setelah update
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}