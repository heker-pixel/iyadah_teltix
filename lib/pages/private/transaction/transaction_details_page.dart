import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'transaction_model.dart';
import 'transaction_controller.dart';
import '../../private/users/user_controller.dart'; // Update with correct import path
import '../../private/movies/movies_controller.dart'; // Update with correct import path

class TransactionDetailsPage extends StatelessWidget {
  final Transaction transaction;
  final TransactionController _transactionController = TransactionController();
  final UserController _userController = UserController();
  final MovieController _movieController = MovieController();

  TransactionDetailsPage({required this.transaction});

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

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('yyyy/MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction Details',
          style: TextStyle(
              color: Colors.white), // Setting title text color to white
        ),
        iconTheme:
            IconThemeData(color: Colors.white), // Setting icon color to white
        backgroundColor:
            Colors.grey.shade900, // Setting AppBar background color
        centerTitle: true, // Centering the title text
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction ID: ${transaction.id}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            FutureBuilder<String>(
              future: _userController.getUserEmail(transaction.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final email = snapshot.data ?? '';
                  return Text('User Email: $email');
                }
              },
            ),
            SizedBox(height: 8),
            FutureBuilder<String>(
              future: _movieController.getMovieTitle(transaction.movieId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final movieTitle = snapshot.data ?? '';
                  return Text('Movie Title: $movieTitle');
                }
              },
            ),
            SizedBox(height: 8),
            Text(
                'Transaction Date: ${formatDate(transaction.transactionDate)}'),
            SizedBox(height: 8),
            Text('Total Amount: ${transaction.totalAmount}'),
            SizedBox(height: 8),
            Text('Total Price: ${formatCurrency(transaction.totalPrice)}'),
            SizedBox(height: 16),
            Text('E-Tickets:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _transactionController
                  .getETicketsForTransaction(transaction.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No e-tickets found.');
                }

                final eTickets = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: eTickets.map((eTicket) {
                    return Text('Ticket Code: ${eTicket['ticket_code']}');
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
