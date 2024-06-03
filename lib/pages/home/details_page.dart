import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../utils/db_connect.dart';
import '../../utils/app_provider.dart';
import 'transaction_success_page.dart'; // Import the new page
import '../private/transaction/transaction_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
    _loadUserData();
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

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found.')),
      );
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buy Tickets'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Enter the number of tickets you want to buy:'),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    totalAmount = int.tryParse(value) ?? 1;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Buy'),
              onPressed: () async {
                try {
                  final int ticketPrice = _movie!['ticket_price'];
                  final transactionId =
                      await widget.transactionController.createTransaction(
                    {
                      'user_id': _userId,
                      'movie_id': widget.movieId,
                      'transaction_date': DateTime.now().toIso8601String(),
                      'total_amount': totalAmount,
                      'total_price': ticketPrice * totalAmount,
                    },
                    totalAmount,
                    'TICKET',
                  );

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => TransactionSuccessPage(
                        transactionId: transactionId,
                        totalAmount: totalAmount,
                        totalPrice: ticketPrice * totalAmount,
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transaction failed: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMovieDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _movie!['poster'] != null
                ? Image.memory(Uint8List.fromList(_movie!['poster']))
                : Container(height: 200, color: Colors.grey),
            SizedBox(height: 16),
            Text('Title: ${_movie!['title']}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Genre: ${_movie!['genre']}'),
            SizedBox(height: 8),
            Text('Duration: ${_movie!['duration']}'),
            SizedBox(height: 8),
            Text('Director: ${_movie!['director']}'),
            SizedBox(height: 8),
            Text('Producer: ${_movie!['producer']}'),
            SizedBox(height: 8),
            Text('Cast: ${_movie!['cast']}'),
            SizedBox(height: 8),
            Text('Synopsis: ${_movie!['synopsis']}'),
            SizedBox(height: 8),
            Text('Show Time: ${_movie!['show_time']}'),
            SizedBox(height: 8),
            Text('Release Date: ${_movie!['release_date']}'),
            SizedBox(height: 8),
            Text('Ticket Price: \$${_movie!['ticket_price']}'),
            SizedBox(height: 8),
            Text('Ticket Count: ${_movie!['ticket_count']}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _movie == null
              ? Center(child: Text('Movie not found.'))
              : _buildMovieDetails(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTransactionDialog,
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}
