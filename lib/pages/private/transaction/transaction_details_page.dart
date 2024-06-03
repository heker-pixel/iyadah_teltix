import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'transaction_controller.dart';

class TransactionDetailsPage extends StatelessWidget {
  final Transaction transaction;
  final TransactionController _transactionController = TransactionController();

  TransactionDetailsPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: ${transaction.id}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('User ID: ${transaction.userId}'),
            SizedBox(height: 8),
            Text('Movie ID: ${transaction.movieId}'),
            SizedBox(height: 8),
            Text('Transaction Date: ${transaction.transactionDate}'),
            SizedBox(height: 8),
            Text('Total Amount: ${transaction.totalAmount}'),
            SizedBox(height: 8),
            Text('Total Price: \$${transaction.totalPrice}'),
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
