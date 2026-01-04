import 'package:path/path.dart';
import 'package:review_film/sqlite/json/users.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final dbName = 'reviews.db';

  //tables
  String user = ''''
    CREATE TABLE user (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL
    )
  ''';
  //CONNECT DB
  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(user);
      },
    );
  }
  //FUNCTION METHOD

  //AUTHENTICATION
  Future<bool> authenticate(Users usr) async {
    final Database db = await initDB();
    var result = await db.query(
      "select * from user where email = '${usr.email}' and password = '${usr.password}'",
      whereArgs: [usr.email, usr.password],
    );
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //SIGN UP
  Future<int> register(Users usr) async {
    final Database db = await initDB();
    var result = await db.insert('user', usr.toMap());
    return result;
  }

  //GET USER DETAIL
  Future<Users?> getUserDetail(String email) async {
    final Database db = await initDB();
    var result = await db.query("user", where: "email = ?", whereArgs: [email]);
    if (result.isNotEmpty) {
      return Users.fromMap(result.first);
    }
    return null;
  }


}
