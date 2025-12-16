import 'package:flutter/material.dart';
import 'package:review_film/data/film_data.dart';
import 'package:review_film/model/film_model.dart';
import 'package:review_film/widgets/film_card.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Review List'),
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
                color: Colors.amber,
              ),
              child: TextField(
                autofocus: false,
                decoration: InputDecoration(
                  // TODO 6 Implementasi fitur pencarian
                  hintText: 'Cari candi ...',
                  prefixIcon: Icon(Icons.search),
                  //TODO 7 Implementasi pemasangan input
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: GridView.builder(
                itemCount: filmList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final Film film =filmList[index];
            return FilmCard(film: film,);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
