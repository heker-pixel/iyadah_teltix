import 'package:flutter/material.dart';
import 'transaction_controller.dart';
import 'transaction_details_page.dart';
import 'transaction_model.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TransactionController _transactionController = TransactionController();
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _transactionController.getAllTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No transactions found.'));
          }

          final transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];

              return ListTile(
                title: Text('Transaction ID: ${transaction.id}'),
                subtitle: Text('Date: ${transaction.transactionDate}'),
                trailing: PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'details',
                      child: ListTile(
                        leading: Icon(Icons.info),
                        title: Text('View Details'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                  onSelected: (String value) async {
                    if (value == 'details') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TransactionDetailsPage(transaction: transaction),
                        ),
                      );
                    } else if (value == 'delete') {
                      await _transactionController
                          .deleteTransaction(transaction.id);
                      setState(() {
                        _transactionsFuture =
                            _transactionController.getAllTransactions();
                      });
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
