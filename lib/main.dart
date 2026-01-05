import 'package:flutter/material.dart';
import 'package:review_film/pages/my_review_page.dart';
import 'package:review_film/pages/profile_page.dart';
import 'package:review_film/pages/search_page.dart';
import 'pages/login_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'sqlite/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      await _initializeDatabase();
    } catch (e) {
      print('❌ Error initializing database: $e');
    }
  }

  runApp(const MyApp());
}

Future<void> _initializeDatabase() async {
  final dbHelper = DatabaseHelper();
  print('Checking database status...');
  await dbHelper.database;
  print('Database initialized successfully.');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Review Film',
      theme: ThemeData(
        primaryColor: const Color(0xFF4F4A3F),
        scaffoldBackgroundColor: const Color(0xFFD6D2C4),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F4A3F)),
      ),
      home: const LoginPage(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String userEmail; 

  const MainScreen({super.key, required this.userEmail});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      MyReviewPage(), 
      SearchPage(),
      ProfilePage(userEmail: widget.userEmail), 
    ];

    return Scaffold(
      body: children[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF4F4A3F), // Background color of nav bar
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white38,
          showUnselectedLabels: false,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}