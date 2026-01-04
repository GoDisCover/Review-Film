import 'package:flutter/material.dart';
import 'package:review_film/pages/my_review_page.dart';
import 'package:review_film/pages/profile_page.dart';
import 'package:review_film/pages/search_page.dart';
import 'pages/login_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'sqlite/database_helper.dart';

void main() async {
  // ✅ TAMBAHKAN async
  WidgetsFlutterBinding.ensureInitialized(); // ✅ TAMBAHKAN INI

  // ✅ TAMBAHKAN - Inisialisasi database untuk non-web platform
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
  await dbHelper.initDB();
  print('Database initialized successfully.');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: const LoginPage(),
      home: LoginPage(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _curentIndex = 0;
  final List<Widget> _children = [MyReviewPage(), SearchPage(), ProfilePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_curentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.deepPurple),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _curentIndex,
          selectedItemColor: Colors.amber[800],

          showUnselectedLabels: false,
          onTap: (index) {
            setState(() {
              _curentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
