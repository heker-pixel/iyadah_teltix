import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../utils/db_connect.dart';
import '../../utils/app_provider.dart';
import '../private/transaction/transaction_controller.dart';
import '../../build_page.dart';
import 'dart:async';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sqflite/sqflite.dart';

class DetailsPage extends StatefulWidget {
  final int movieId;
  final TransactionController transactionController =
      TransactionController(); // Initialize TransactionController

  DetailsPage({required this.movieId});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Map<String, dynamic>? _movie;
  bool _isLoading = true;
  int? _userId;
  bool isExpanded = false;
  bool _isInWatchlist = false;
  dynamic _userRating;
  bool hasRated = false;

  final StreamController<double> _averageRatingStreamController =
      StreamController<double>();
  final StreamController<int> _watchlistCountStreamController =
      StreamController<int>();
  final StreamController<int> _ratingsCountStreamController =
      StreamController<int>();

  Stream<double> get averageRatingStream =>
      _averageRatingStreamController.stream;
  Stream<int> get watchlistCountStream =>
      _watchlistCountStreamController.stream;
  Stream<int> get ratingsCountStream => _ratingsCountStreamController.stream;

  Future<void> _checkWatchlistStatus() async {
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final userEmail = appProvider.userEmail;

      final db = await DBConnect().database;
      final List<Map<String, dynamic>> userData = await db.query(
        'users',
        columns: ['id'],
        where: 'email = ?',
        whereArgs: [userEmail],
      );

      if (userData.isNotEmpty) {
        final _userId = userData.first['id'] as int;
        final result = await db.query(
          'watchlist',
          where: 'user_id = ? AND movie_id = ?',
          whereArgs: [_userId, widget.movieId],
        );
        final isInWatchlist = result.isNotEmpty;
        setState(() {
          _isInWatchlist = isInWatchlist;
        });
      }
    } catch (e) {
      _showSnackbar('Error checking watchlist status: $e');
      print('Error checking watchlist status: $e');
    }
  }

  Future<void> _checkUserRating() async {
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final userEmail = appProvider.userEmail;

      final db = await DBConnect().database;
      final List<Map<String, dynamic>> userData = await db.query(
        'users',
        columns: ['id'],
        where: 'email = ?',
        whereArgs: [userEmail],
      );

      if (userData.isNotEmpty) {
        final _userId = userData.first['id'] as int;
        final result = await db.query(
          'ratings',
          where: 'user_id = ? AND movie_id = ?',
          whereArgs: [_userId, widget.movieId],
        );
        final userRating = result.isNotEmpty ? result.first['rating'] : null;
        setState(() {
          _userRating = userRating;
          hasRated = userRating != null;
        });
      }
    } catch (e) {
      _showSnackbar('Error checking user rating: $e');
      print('Error checking user rating: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
    _loadUserData();
    _getAverageRating();
    _getWatchlistCount();
    _getRatingsCount();
    _checkWatchlistStatus();
    _checkUserRating();
  }

  @override
  void dispose() {
    _averageRatingStreamController.close();
    _watchlistCountStreamController.close();
    _averageRatingStreamController.close();
    super.dispose();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final db = await DBConnect().database;
      final List<Map<String, dynamic>> result = await db.query(
        'movies',
        where: 'id = ?',
        whereArgs: [widget.movieId],
      );

      if (result.isNotEmpty) {
        setState(() {
          _movie = result.first;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading movie details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final userEmail = appProvider.userEmail;

      final db = await DBConnect().database;
      final List<Map<String, dynamic>> userData = await db.query(
        'users',
        columns: ['id'],
        where: 'email = ?',
        whereArgs: [userEmail],
      );

      if (userData.isNotEmpty) {
        setState(() {
          _userId = userData.first['id'];
        });
      } else {
        print('User not found for email: $userEmail');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _showTransactionDialog() async {
    int totalAmount = 1;
    int ticketPrice = _movie!['ticket_price'];
    int ticketsLeft = _movie!['ticket_count'];
    int totalPrice = ticketPrice * totalAmount;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white, // Set background color to white

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              titlePadding: EdgeInsets.all(0),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(0),
              title: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.local_movies,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Buy Tickets',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              content: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter the number of tickets you want to buy:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              totalAmount =
                                  totalAmount > 1 ? totalAmount - 1 : 1;
                              totalPrice = ticketPrice * totalAmount;
                            });
                          },
                        ),
                        Text(
                          '$totalAmount',
                          style: TextStyle(fontSize: 20),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              if (totalAmount < ticketsLeft) {
                                totalAmount++;
                                totalPrice = ticketPrice * totalAmount;
                              } else {
                                // Show validation message
                                totalPrice = ticketPrice * totalAmount;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${formatCurrency(totalPrice)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Show number of tickets left
                    Text(
                      'Tickets Left: $ticketsLeft',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: ticketsLeft > 0 ? Colors.grey : Colors.red,
                      ),
                    ),
                    // Validation message
                    if (totalAmount >= ticketsLeft)
                      Text(
                        'And that was the last ticket',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.0,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                Container(
                  padding: EdgeInsets.only(bottom: 16.0),
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey.shade900,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () async {
                              try {
                                final transactionId = await widget
                                    .transactionController
                                    .createTransaction(
                                  {
                                    'user_id': _userId,
                                    'movie_id': widget.movieId,
                                    'transaction_date':
                                        DateTime.now().toIso8601String(),
                                    'total_amount': totalAmount,
                                    'total_price': totalPrice,
                                  },
                                  totalAmount,
                                  'TICKET',
                                );

                                Navigator.of(context).pop(); // Close the dialog
                                _showSuccessModal(context, transactionId,
                                    totalAmount, totalPrice);
                              } catch (e) {
                                totalPrice = ticketPrice * totalAmount;
                              }
                            },
                            child: Text('Buy'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSuccessModal(BuildContext context, int transactionId,
      int totalAmount, int totalPrice) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Success!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Your transaction was successful.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Transaction ID: $transactionId',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tickets Purchased: $totalAmount',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Total Price: ${formatCurrency(totalPrice)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Close the success modal
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => buildPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.grey.shade900, // Background color
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Adjust the radius as needed
                            ),
                          ),
                          child: Text('OK'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatCurrency(int price) {
    final priceStr = price.toString();
    final length = priceStr.length;
    String formattedPrice = 'Rp';

    for (var i = 0; i < length; i++) {
      formattedPrice += priceStr[i];
      if ((length - i - 1) % 3 == 0 && i != length - 1) {
        formattedPrice += '.';
      }
    }

    return formattedPrice;
  }

  Future<void> _showRatingDialog() async {
    double? userRating;
    if (_userRating != null) {
      userRating = _userRating.toDouble();
    } else {
      userRating = 0.0;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.white,
                ),
                width: double.infinity, // Adjusts the width of the container
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width:
                          double.infinity, // Adjusts the width of the container
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade700,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Rate this movie',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          RatingBar.builder(
                            initialRating: userRating ?? 0.0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                userRating = rating;
                              });
                            },
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Your rating: ${userRating ?? 0}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey.shade900,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.yellow.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  final db = await DBConnect().database;
                                  if (_userRating == null) {
                                    await db.insert('ratings', {
                                      'user_id': _userId,
                                      'movie_id': widget.movieId,
                                      'rating': userRating,
                                    });
                                  } else {
                                    await db.update(
                                      'ratings',
                                      {
                                        'rating': userRating,
                                      },
                                      where: 'user_id = ? AND movie_id = ?',
                                      whereArgs: [_userId, widget.movieId],
                                    );
                                  }
                                  setState(() {
                                    _userRating = userRating;
                                    hasRated = true;
                                  });
                                  _getAverageRating(); // Update the average rating
                                  _getRatingsCount();
                                  _checkUserRating();
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Thanks for rating!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } catch (e) {
                                  print('Error saving rating: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to save rating'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: Text('Rate'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<int> _getWatchlistCount() async {
    try {
      final db = await DBConnect().database;
      final result = await db.query('watchlist',
          where: 'movie_id = ?', whereArgs: [widget.movieId]);
      _watchlistCountStreamController.add(result.length);
      return result.length;
    } catch (e) {
      print('Error fetching watchlist count: $e');
      return 0;
    }
  }

  Future<int> _getRatingsCount() async {
    try {
      final db = await DBConnect().database;
      final result = await db
          .query('ratings', where: 'movie_id = ?', whereArgs: [widget.movieId]);
      _ratingsCountStreamController.add(result.length);
      return result.length;
    } catch (e) {
      print('Error fetching watchlist count: $e');
      return 0;
    }
  }

  Future<double> _getAverageRating() async {
    try {
      final db = await DBConnect().database;
      final result = await db.rawQuery(
          'SELECT AVG(rating) FROM ratings WHERE movie_id = ?',
          [widget.movieId]);
      final averageRating = (result.first.values.first ?? 0) as double;
      _averageRatingStreamController.add(averageRating);
      return averageRating;
    } catch (e) {
      print('Error fetching average rating: $e');
      return 0.0;
    }
  }

  Future<void> _toggleWatchlist() async {
    try {
      final db = await DBConnect().database;
      if (_isInWatchlist) {
        await db.delete(
          'watchlist',
          where: 'user_id = ? AND movie_id = ?',
          whereArgs: [_userId, widget.movieId],
        );
        setState(() {
          _isInWatchlist = false;
        });
      } else {
        await db.insert('watchlist', {
          'user_id': _userId,
          'movie_id': widget.movieId,
        });
        setState(() {
          _isInWatchlist = true;
        });
      }
      _getWatchlistCount();
    } catch (e) {
      print('Error toggling watchlist status: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _movie == null
              ? Center(child: Text('Movie not found.'))
              : CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      title: Text('Movie Details',
                          style: TextStyle(color: Colors.white)),
                      centerTitle: true,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      pinned: true,
                      expandedHeight: 200.0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.memory(
                          Uint8List.fromList(_movie!['poster']),
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.darken,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      backgroundColor: Colors.grey.shade900,
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _movie!['poster'] != null
                                    ? Image.memory(
                                        Uint8List.fromList(_movie!['poster']),
                                        width: 100,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 100,
                                        height: 150,
                                        color: Colors.grey,
                                        child: Center(child: Text('No image')),
                                      ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${_movie!['title']}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildGenre(_movie!['genre']),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Duration : ${_movie!['duration']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Showtime : ${_movie!['show_time']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Release Date : ${_movie!['release_date']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Ensuring equal spacing between children
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: _toggleWatchlist,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isInWatchlist
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Watchlist',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                                height:
                                                    4), // Added SizedBox for spacing
                                            StreamBuilder<int>(
                                              stream: watchlistCountStream,
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return Text('Loading...');
                                                } else {
                                                  return Text(
                                                    '${snapshot.data} users added',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width: 16), // Added SizedBox for spacing
                                Container(
                                  height: 50,
                                  width:
                                      1, // Specifying width to avoid overflow
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                    width: 16), // Added SizedBox for spacing
                                Expanded(
                                  child: InkWell(
                                    onTap: _showRatingDialog,
                                    child: Row(
                                      children: [
                                        Icon(
                                          hasRated
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                        ),
                                        SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Rate Movie',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                                height:
                                                    4), // Added SizedBox for spacing
                                            StreamBuilder<double>(
                                              stream: averageRatingStream,
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return Text('Loading...');
                                                } else {
                                                  final averageRating =
                                                      snapshot.data!;
                                                  final roundedRating =
                                                      averageRating
                                                          .toStringAsFixed(1);
                                                  return Text(
                                                    '$roundedRating/5',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  );
                                                }
                                              },
                                            ),
                                            SizedBox(
                                                height:
                                                    4), // Added SizedBox for spacing
                                            StreamBuilder<int>(
                                              stream: ratingsCountStream,
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return Text(
                                                    'Loading...',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  );
                                                } else {
                                                  final ratingCount =
                                                      snapshot.data!;
                                                  return Text(
                                                    '$ratingCount users',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Movie Synopsis',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedCrossFade(
                                      firstChild: Text(
                                        _movie!['synopsis'],
                                        style: TextStyle(fontSize: 18),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      secondChild: Text(
                                        _movie!['synopsis'],
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      crossFadeState: isExpanded
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      duration: Duration(milliseconds: 300),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isExpanded = !isExpanded;
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            isExpanded
                                                ? 'Read less'
                                                : 'Read more',
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                          Icon(
                                            isExpanded
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: Colors.blue,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Movie Production',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ..._buildProfileItems(
                                      _movie!['director'], 'Director'),
                                  ..._buildProfileItems(
                                      _movie!['producer'], 'Producer'),
                                  ..._buildProfileItems(
                                      _movie!['cast'], 'Cast'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _movie != null &&
              _movie!['ticket_count'] > 0 &&
              DateTime.now().isBefore(DateTime(
                      int.parse(_movie!['release_date'].split('/')[2]) < 100
                          ? (int.parse(_movie!['release_date'].split('/')[2]) >=
                                  50
                              ? int.parse(
                                      _movie!['release_date'].split('/')[2]) +
                                  1900
                              : int.parse(
                                      _movie!['release_date'].split('/')[2]) +
                                  2000)
                          : int.parse(_movie!['release_date'].split('/')[2]),
                      int.parse(_movie!['release_date'].split('/')[1]),
                      int.parse(_movie!['release_date'].split('/')[0]))
                  .add(Duration(days: 1)))
          ? FloatingActionButton(
              onPressed: _showTransactionDialog,
              backgroundColor: Colors.yellow.shade700,
              foregroundColor: Colors.white,
              child: Icon(Icons.shopping_cart),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                // Do nothing when button is disabled
              },
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.white,
              label: Text('Tickets are not available'),
              icon: Icon(Icons.shopping_cart),
            ),
    );
  }

  List<Widget> _buildProfileItems(String names, String job) {
    final nameList = names.split(',').map((name) => name.trim()).toList();
    return nameList.map((name) => ProfileItem(name: name, job: job)).toList();
  }

  Widget buildGenre(String genre) {
    final genreList = genre.split(',').map((genre) => genre.trim()).toList();
    final joinedGenres = genreList.join(' | ');
    return Text(
      'Genre : ${joinedGenres}',
      style: TextStyle(fontSize: 16),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String name;
  final String job;

  ProfileItem({required this.name, required this.job});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0), // Adjust spacing as needed
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          CircleAvatar(
            backgroundColor: Colors.black,
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          SizedBox(height: 4),
          Text(
            job,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            name,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
