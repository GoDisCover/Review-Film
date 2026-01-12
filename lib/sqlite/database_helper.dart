import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:review_film/data/film_data.dart';
import 'package:review_film/model/film_model.dart';
import 'package:review_film/sqlite/json/users.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  final String dbName = 'reviews_v5.db';

  // 1. Tabel User
  String userTable = '''
    CREATE TABLE user (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL
    )
  ''';

  // 2. Tabel Film
  String filmTable = '''
    CREATE TABLE films (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_film TEXT NOT NULL,
      description TEXT NOT NULL,
      image_url TEXT NOT NULL,
      genre TEXT NOT NULL
    )
  ''';

  // 3. Tabel Reviews
  String reviewTable = '''
    CREATE TABLE reviews (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_email TEXT NOT NULL,
      film_id INTEGER NOT NULL,
      rating REAL NOT NULL,
      date TEXT,
      FOREIGN KEY (film_id) REFERENCES films (id)
    )
  ''';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(dbName, version: 1, onCreate: _onCreate);
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final appDocumentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(appDocumentsDirectory.path, dbName);
      print('📁 Database location (Desktop): $path');
      return await openDatabase(path, version: 1, onCreate: _onCreate);
    }

    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);
    print('📁 Database location (Mobile): $path');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(userTable);
    await db.execute(filmTable);
    await db.execute(reviewTable);

    // Insert data awal film jika ada
    if (filmList.isNotEmpty) {
      for (var film in filmList) {
        var filmMap = film.toMap();
        // Hapus field yang tidak ada di tabel films jika model Film memiliki rating/id
        filmMap.remove('rating');
        filmMap.remove('id');

        await db.insert('films', filmMap);
      }
    }
    print("✅ Database Berhasil Dibuat Lengkap!");
  }

  // --- AUTH METHODS ---

  Future<bool> authenticate(Users usr) async {
    final db = await database;
    var result = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [usr.email, usr.password],
    );
    return result.isNotEmpty;
  }

  Future<int> register(Users usr) async {
    final db = await database;
    try {
      return await db.insert('user', usr.toMap());
    } catch (e) {
      return -1;
    }
  }

  Future<Users?> getUserDetail(String email) async {
    final db = await database;
    var result = await db.query("user", where: "email = ?", whereArgs: [email]);
    if (result.isNotEmpty) {
      return Users.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateUser(Users user) async {
    final db = await database;
    return await db.update(
      'user',
      user.toMap(),
      where: 'email = ?',
      whereArgs: [user.email],
    );
  }

  // --- FILM METHODS ---

  Future<List<Film>> getAllFilms() async {
    final db = await database;
    // LEFT JOIN untuk mengambil rata-rata rating global
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        f.*, 
        COALESCE(AVG(r.rating), 0.0) as rating 
      FROM films f
      LEFT JOIN reviews r ON f.id = r.film_id
      GROUP BY f.id
    ''');

    return List.generate(maps.length, (i) {
      return Film.fromMap(maps[i]);
    });
  }

  Future<List<Film>> getMyFilms(String email) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        f.*, 
        r.rating as rating 
      FROM films f
      JOIN reviews r ON f.id = r.film_id
      WHERE r.user_email = ?
      ORDER BY r.id DESC
    ''', [email]);

    return List.generate(maps.length, (i) {
      return Film.fromMap(maps[i]);
    });
  }

  // --- RATING SPECIFIC METHODS (BARU) ---

  // 1. Ambil ID Film berdasarkan Nama (Helper)
  Future<int?> _getFilmIdByName(String filmTitle) async {
    final db = await database;
    final res = await db.query(
      'films',
      columns: ['id'],
      where: 'nama_film = ?',
      whereArgs: [filmTitle],
    );
    if (res.isNotEmpty) {
      return res.first['id'] as int;
    }
    return null;
  }

  // 2. Ambil Rating User Spesifik (Your Rating)
  Future<double> getSpecificUserRating(String email, String filmTitle) async {
    final db = await database;
    final filmId = await _getFilmIdByName(filmTitle);

    if (filmId == null) return 0.0;

    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      columns: ['rating'],
      where: 'user_email = ? AND film_id = ?',
      whereArgs: [email, filmId],
    );

    if (maps.isNotEmpty) {
      return maps.first['rating'] as double;
    }
    return 0.0;
  }

  // 3. Update atau Insert Rating (Untuk Edit Rating)
  Future<void> updateUserRating(String email, String filmTitle, double newRating) async {
    final db = await database;
    final filmId = await _getFilmIdByName(filmTitle);

    // Cek apakah user sudah pernah review film ini
    final List<Map<String, dynamic>> check = await db.query(
      'reviews',
      where: 'user_email = ? AND film_id = ?',
      whereArgs: [email, filmId],
    );

    if (check.isNotEmpty) {
      // UPDATE jika sudah ada
      await db.update(
        'reviews',
        {'rating': newRating, 'date': DateTime.now().toString()},
        where: 'user_email = ? AND film_id = ?',
        whereArgs: [email, filmId],
      );
    } else {
      // INSERT jika belum ada
      await db.insert('reviews', {
        'user_email': email,
        'film_id': filmId,
        'rating': newRating,
        'date': DateTime.now().toString(),
      });
    }
  }

  // 4. Ambil Rating Global (Rata-rata semua user)
  Future<double> getGlobalRating(String filmTitle) async {
    final db = await database;
    final filmId = await _getFilmIdByName(filmTitle);

    if (filmId == null) return 0.0;

    final result = await db.rawQuery('''
      SELECT AVG(rating) as avg_rating 
      FROM reviews 
      WHERE film_id = ?
    ''', [filmId]);

    if (result.isNotEmpty && result.first['avg_rating'] != null) {
      return result.first['avg_rating'] as double;
    }
    return 0.0;
  }
}