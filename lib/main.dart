import 'package:flutter/material.dart';
import 'package:review_film/pages/my_review_page.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: const LoginPage(),
      home: const MyReviewPage()
    );
  }
}
