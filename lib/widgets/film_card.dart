import 'package:flutter/material.dart';

class FilmCard extends StatelessWidget {
  const FilmCard({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          print('Test');
        },
        child: Stack(
          children: [
            Image.network(
              'https://cdn.myanimelist.net/images/anime/1255/110636.jpg',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0x0057564F), Color(0xFF57564F)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
