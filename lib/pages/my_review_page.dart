import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:review_film/data/film_data.dart';
import 'package:review_film/model/film_model.dart';
import 'package:review_film/widgets/film_card.dart';

class MyReviewPage extends StatelessWidget {
  const MyReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Review List'),
        backgroundColor: const Color(0xffDDDAD0),
      ),
      backgroundColor: const Color(0xffDDDAD0),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: GridView.builder(
          itemCount: filmList.length  ,
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
    );
  }
}
