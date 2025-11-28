import 'package:flutter/material.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: GridView.builder(
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (BuildContext context, int index) {
            return FilmCard();
          },
        ),
      ),
    );
  }
}