import 'package:flutter/material.dart';
import 'transaction_controller.dart';
import 'transaction_details_page.dart';
import 'transaction_model.dart';
import '../../../comps/animate_route.dart';
import '../dashboard_page.dart';
import '../../private/movies/movies_controller.dart'; // Import the movies controller
import '../../private/users/user_controller.dart'; // Import the user controller

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TransactionController _transactionController = TransactionController();
  final UserController _userController =
      UserController(); // Instantiate user controller
  final MovieController _moviesController =
      MovieController(); // Instantiate movies controller
  late Future<List<Transaction>> _transactionsFuture;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _transactionController.getAllTransactions();
    _searchController.addListener(_searchTransactions);
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchTransactions);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchTransactions() async {
    final query = _searchController.text;
    setState(() {
      _transactionsFuture = _transactionController.searchTransactions(query);
    });
  }

  void _confirmDeleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(0),
          actionsPadding: EdgeInsets.all(0),
          title: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.yellow.shade700,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Confirm Delete',
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
            child: Text(
              'Are you sure you want to delete this transaction?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
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
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _deleteTransaction(transaction);
                        },
                        child: Text('Delete'),
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
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    await _transactionController.deleteTransaction(transaction.id);
    setState(() {
      _transactionsFuture = _transactionController.getAllTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 14.0,
                ),
                controller: _searchController,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 3.5,
                    horizontal: 12.0,
                  ),
                  hintText: 'Search Transactions',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 14.0,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              )
            : Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.credit_card, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Transactions', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade900,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(animatedDart(
              Offset(-1.0, 0.0),
              DashboardPage(),
            ));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/search.jpg',
                    width: 250,
                    height: 150,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No Transaction Found",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          final transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: _getUserAndMovieData(transactions[index]),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final data = snapshot.data!;
                    final transaction = transactions[index];
                    return ListTile(
                      title: Text(
                        'Transaction ID: ${transaction.id}',
                        style: TextStyle(
                            fontWeight:
                                FontWeight.bold), // Make transaction ID bold
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User Email: ${data['userEmail']}'),
                          Text('Movie Title: ${data['movieTitle']}'),
                          Text('Date: ${data['formattedDate']}'),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'details',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(
                                    width: 6), // Space between icon and text
                                Text('Details'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(
                                    width: 6), // Space between icon and text
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                        color: Colors.white, // Set dropdown background color
                        onSelected: (String value) async {
                          if (value == 'details') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionDetailsPage(
                                    transaction: transaction),
                              ),
                            );
                          } else if (value == 'delete') {
                            _confirmDeleteTransaction(transaction);
                          }
                        },
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, String>> _getUserAndMovieData(
      Transaction transaction) async {
    final userEmail = await _userController.getUserEmail(transaction.userId);
    final movieTitle =
        await _moviesController.getMovieTitle(transaction.movieId);
    final formattedDate =
        DateTime.parse(transaction.transactionDate).toString().substring(0, 10);
    return {
      'userEmail': userEmail,
      'movieTitle': movieTitle,
      'formattedDate': formattedDate
    };
  }
}
