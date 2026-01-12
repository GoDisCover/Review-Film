import 'package:flutter/material.dart';
import 'package:review_film/pages/my_review_page.dart';
import 'package:review_film/pages/profile_page.dart';
import 'package:review_film/pages/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'sqlite/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Database (Khusus Desktop/Mobile)
  if (!kIsWeb) {
    try {
      await _initializeDatabase();
    } catch (e) {
      print('❌ Error initializing database: $e');
    }
  }

  // Cek Login Session
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedEmail = prefs.getString('user_email');

  runApp(MyApp(initialEmail: savedEmail));
}

Future<void> _initializeDatabase() async {
  final dbHelper = DatabaseHelper();
  print('Checking database status...');
  await dbHelper.database;
  print('Database initialized successfully.');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialEmail});
  final String? initialEmail;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Review Film',
      theme: ThemeData(
        primaryColor: const Color(0xFF4F4A3F),
        scaffoldBackgroundColor: const Color(0xFFD6D2C4),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F4A3F)),
        useMaterial3: true,
      ),
      // Jika ada email tersimpan -> MainScreen, jika tidak -> LoginPage
      home: initialEmail != null
          ? MainScreen(userEmail: initialEmail!)
          : const LoginPage(),
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
    // List Halaman
    final List<Widget> children = [
      MyReviewPage(userEmail: widget.userEmail),
      SearchPage(userEmail: widget.userEmail),
      ProfilePage(userEmail: widget.userEmail),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: children,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF4F4A3F),
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