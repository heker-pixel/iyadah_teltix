import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBConnect {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      String path = join(await getDatabasesPath(), 'kajshdjkadhsidhaiu.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      throw Exception('Error initializing database: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        level TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS movies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        genre TEXT NOT NULL,
        duration TEXT NOT NULL,
        director TEXT NOT NULL,
        producer TEXT NOT NULL,
        cast TEXT NOT NULL,
        synopsis TEXT NOT NULL,
        show_time TEXT NOT NULL,
        release_date TEXT NOT NULL,
        ticket_price INTEGER NOT NULL,
        ticket_count INTEGER NOT NULL,
        poster BLOB
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        movie_id INTEGER NOT NULL,
        transaction_date TEXT NOT NULL,
        total_amount INTEGER NOT NULL,
        total_price INTEGER NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(movie_id) REFERENCES movies(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS e_tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        ticket_code TEXT NOT NULL,
        FOREIGN KEY(transaction_id) REFERENCES transactions(id)
      )
    ''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS banners (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      image BLOB NOT NULL
    )
  ''');
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final db = await database;
      return await db.insert(table, data);
    } catch (e) {
      throw Exception('Error inserting data into $table: $e');
    }
  }

  Future<int> update(String table, Map<String, dynamic> data,
      String whereClause, List whereArgs) async {
    try {
      final db = await database;
      return await db.update(table, data,
          where: whereClause, whereArgs: whereArgs);
    } catch (e) {
      throw Exception('Error updating data in $table: $e');
    }
  }

  Future<int> delete(String table, String whereClause, List whereArgs) async {
    try {
      final db = await database;
      return await db.delete(table, where: whereClause, whereArgs: whereArgs);
    } catch (e) {
      throw Exception('Error deleting data from $table: $e');
    }
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    try {
      final db = await database;
      return await db.query(table);
    } catch (e) {
      throw Exception('Error querying all data from $table: $e');
    }
  }

  Future<List<Map<String, dynamic>>> query(
      String table, String whereClause, List whereArgs) async {
    try {
      final db = await database;
      return await db.query(table, where: whereClause, whereArgs: whereArgs);
    } catch (e) {
      throw Exception('Error querying data from $table: $e');
    }
  }

  Future<int> saveImage(int movieId, Uint8List imageBytes) async {
    try {
      final db = await database;
      return await db.update(
        'movies',
        {'poster': imageBytes},
        where: 'id = ?',
        whereArgs: [movieId],
      );
    } catch (e) {
      throw Exception('Error saving image: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final db = await database;
    return await db.query(
      'movies',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  Future<List<Map<String, dynamic>>> searchFigure(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> castResults = await db.query(
      'movies',
      where: ' "cast" LIKE ?',
      whereArgs: ['%$query%'],
    );
    final List<Map<String, dynamic>> producerResults = await db.query(
      'movies',
      where: 'producer LIKE ?',
      whereArgs: ['%$query%'],
    );
    final List<Map<String, dynamic>> directorResults = await db.query(
      'movies',
      where: 'director LIKE ?',
      whereArgs: ['%$query%'],
    );
    // Merge the results from cast, producer, and director
    final List<Map<String, dynamic>> allResults = []
      ..addAll(castResults)
      ..addAll(producerResults)
      ..addAll(directorResults);
    return allResults;
  }

  List<String> _splitAndFlatten(
      List<Map<String, dynamic>> results, String key) {
    return results
        .fold<List<String>>([], (prev, curr) {
          final value = curr[key] as String;
          final splitValues = value.split(', ');
          return [...prev, ...splitValues];
        })
        .toSet()
        .toList();
  }

  Future<Uint8List?> getImage(int movieId) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> results = await db.query(
        'movies',
        columns: ['poster'],
        where: 'id = ?',
        whereArgs: [movieId],
      );
      if (results.isNotEmpty && results.first['poster'] != null) {
        List<int> posterBytes = results.first['poster'];
        return Uint8List.fromList(posterBytes);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting image: $e');
    }
  }

  Future<int> insertMovie(Map<String, dynamic> movieData) async {
    return await insert('movies', movieData);
  }

  Future<int> updateMovie(int id, Map<String, dynamic> movieData) async {
    return await update('movies', movieData, 'id = ?', [id]);
  }

  Future<int> deleteMovie(int id) async {
    return await delete('movies', 'id = ?', [id]);
  }

  Future<List<Map<String, dynamic>>> getAllMovies() async {
    return await queryAll('movies');
  }

  Future<int> insertBanner(Uint8List imageBytes) async {
    return await insert('banners', {'image': imageBytes});
  }

  Future<int> updateBanner(int id, Uint8List imageBytes) async {
    return await update('banners', {'image': imageBytes}, 'id = ?', [id]);
  }

  Future<int> deleteBanner(int id) async {
    return await delete('banners', 'id = ?', [id]);
  }

  Future<List<Map<String, dynamic>>> getAllBanners() async {
    return await queryAll('banners');
  }

  Future<Uint8List?> getBannerImage(int id) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> results = await db.query(
        'banners',
        columns: ['image'],
        where: 'id = ?',
        whereArgs: [id],
      );
      if (results.isNotEmpty && results.first['image'] != null) {
        List<int> imageBytes = results.first['image'];
        return Uint8List.fromList(imageBytes);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting banner image: $e');
    }
  }
}
