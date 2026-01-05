import 'package:flutter/material.dart';
import 'package:review_film/model/film_model.dart';
import 'package:review_film/sqlite/database_helper.dart'; // Import Database Helper
import 'package:review_film/widgets/film_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  
  // List to store all films from DB
  List<Film> _allFilms = [];
  
  // List to store filtered results (displayed in GridView)
  List<Film> _foundFilms = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshFilms(); // Load data when page opens
  }

  // 1. Fetch data from SQLite
  void _refreshFilms() async {
    final data = await DatabaseHelper().getAllFilms();
    setState(() {
      _allFilms = data;
      _foundFilms = data; // Initially, show all films
      _isLoading = false;
    });
  }

  // 2. Filter logic
  void _runFilter(String enteredKeyword) {
    List<Film> results = [];
    if (enteredKeyword.isEmpty) {
      // If the search field is empty, show all films
      results = _allFilms;
    } else {
      // Filter based on 'namaFilm' (case insensitive)
      results = _allFilms
          .where((film) =>
              film.namaFilm.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // Refresh the UI
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
                color: const Color(0xFFDDDAD0), // Adjusted color to match theme
              ),
              child: TextField(
                controller: _searchController, // Connect controller
                autofocus: false,
                onChanged: (value) => _runFilter(value), // Call filter on typing
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
                            childAspectRatio: 0.65, // Matches your card ratio
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            // Use _foundFilms, NOT filmList
                            final Film film = _foundFilms[index];
                            return FilmCard(film: film);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}