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
      String path = join(await getDatabasesPath(), 'teltix12909090123.db');
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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS watchlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        movie_id INTEGER NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(movie_id) REFERENCES movies(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        movie_id INTEGER NOT NULL,
        rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
        review TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(movie_id) REFERENCES movies(id)
      )
    ''');
  }

  // CRUD methods for watchlist
  Future<int> addToWatchlist(int userId, int movieId) async {
    final db = await database;
    return await db
        .insert('watchlist', {'user_id': userId, 'movie_id': movieId});
  }

  Future<int> removeFromWatchlist(int userId, int movieId) async {
    final db = await database;
    return await db.delete(
      'watchlist',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, movieId],
    );
  }

  Future<List<Map<String, dynamic>>> getWatchlist(int userId) async {
    final db = await database;
    return await db.query(
      'watchlist',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // CRUD methods for ratings
  Future<int> addRating(
      int userId, int movieId, int rating, String? review) async {
    final db = await database;
    return await db.insert('ratings', {
      'user_id': userId,
      'movie_id': movieId,
      'rating': rating,
      'review': review,
    });
  }

  Future<int> updateRating(
      int userId, int movieId, int rating, String? review) async {
    final db = await database;
    return await db.update(
      'ratings',
      {
        'rating': rating,
        'review': review,
      },
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, movieId],
    );
  }

  Future<int> deleteRating(int userId, int movieId) async {
    final db = await database;
    return await db.delete(
      'ratings',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, movieId],
    );
  }

  Future<List<Map<String, dynamic>>> getRatingsForMovie(int movieId) async {
    final db = await database;
    return await db.query(
      'ratings',
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );
  }

  Future<List<Map<String, dynamic>>> getUserRatings(int userId) async {
    final db = await database;
    return await db.query(
      'ratings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
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

  Future<List<Map<String, dynamic>>> getAllFigures() async {
    final db = await database;
    final List<Map<String, dynamic>> castResults = await db.rawQuery(
      'SELECT DISTINCT `cast` AS name FROM movies WHERE `cast` IS NOT NULL AND `cast` != ""',
    );
    final List<Map<String, dynamic>> producerResults = await db.rawQuery(
      'SELECT DISTINCT producer AS name FROM movies WHERE producer IS NOT NULL AND producer != ""',
    );
    final List<Map<String, dynamic>> directorResults = await db.rawQuery(
      'SELECT DISTINCT director AS name FROM movies WHERE director IS NOT NULL AND director != ""',
    );

    final List<Map<String, dynamic>> allResults = [
      ...castResults.map((result) => {'name': result['name'], 'job': 'Cast'}),
      ...producerResults
          .map((result) => {'name': result['name'], 'job': 'Producer'}),
      ...directorResults
          .map((result) => {'name': result['name'], 'job': 'Director'}),
    ];

    return allResults;
  }

  Future<int?> getUserIdByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
    );
    if (results.isNotEmpty) {
      return results.first['id'] as int?;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> searchFigure(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> castResults = await db.rawQuery(
      'SELECT DISTINCT `cast` AS name FROM movies WHERE `cast` LIKE ?',
      ['%$query%'],
    );
    final List<Map<String, dynamic>> producerResults = await db.rawQuery(
      'SELECT DISTINCT producer AS name FROM movies WHERE producer LIKE ?',
      ['%$query%'],
    );
    final List<Map<String, dynamic>> directorResults = await db.rawQuery(
      'SELECT DISTINCT director AS name FROM movies WHERE director LIKE ?',
      ['%$query%'],
    );

    final List<Map<String, dynamic>> allResults = [
      ...castResults.map((result) => {'name': result['name'], 'job': 'Cast'}),
      ...producerResults
          .map((result) => {'name': result['name'], 'job': 'Producer'}),
      ...directorResults
          .map((result) => {'name': result['name'], 'job': 'Director'}),
    ];

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

  Future<List<WatchlistItem>> getWatchlistWithDetails(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT watchlist.id, watchlist.movie_id as movieId, movies.title, movies.poster
    FROM watchlist
    INNER JOIN movies ON watchlist.movie_id = movies.id
    WHERE watchlist.user_id = ?
  ''', [userId]);

    return results.map((result) {
      return WatchlistItem(
        id: result['id'],
        movieId: result['movieId'],
        title: result['title'],
        poster: result['poster'],
      );
    }).toList();
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

class WatchlistItem {
  final int id;
  final int movieId;
  final String title;
  final Uint8List? poster;

  WatchlistItem({
    required this.id,
    required this.movieId,
    required this.title,
    required this.poster,
  });
}
