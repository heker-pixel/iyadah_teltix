import 'package:flutter/material.dart';
import '../../utils/db_connect.dart'; // Import your DBConnect class
import '../utils/app_provider.dart'; // Import your AppProvider class
import '../pages/home/details_page.dart';
import 'package:intl/intl.dart';

class TicketPage extends StatelessWidget {
  final DBConnect _dbConnect = DBConnect();
  final AppProvider _appProvider = AppProvider();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.white, // Set background color to white
        body: Column(
          children: [
            TabBar(
              indicatorColor: Colors.yellow.shade700, // Change indicator color
              tabs: [
                Tab(
                  child: Text(
                    'Current Tickets',
                    style: TextStyle(color: Colors.black), // Set text color
                  ),
                ),
                Tab(
                  child: Text(
                    'History',
                    style: TextStyle(color: Colors.black), // Set text color
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCurrentTicketsTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildHistoryTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
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
          );
        }

        final transactions = snapshot.data!;
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final transactionDate = DateTime.parse(
                transaction['transaction_date']); // Convert string to DateTime
            final formattedTransactionDate = DateFormat('dd/MM/yy')
                .format(transactionDate); // Format DateTime

            return Card(
              elevation: 0, // No shadow

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              color: Colors.white,
              child: ListTile(
                title: Text(
                  'Transaction ID: ${transaction['transaction_id']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transaction Date: $formattedTransactionDate'),
                    Text('Movie Name: ${transaction['movie_name']}'),
                    Text('Total Tickets: ${transaction['total_tickets']}'),
                    Text(
                      'Total Price: ${formatCurrency(transaction['total_price'])}',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCurrentTicketsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchTickets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
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
                "No Ticket Found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          );
        }

        final tickets = snapshot.data!;
        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            final movieId = ticket['movie_id']; // Add null check
            return Card(
              margin: EdgeInsets.all(8.0),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: Colors.grey[900]!, // Border color
                  width: 1.5, // Border width
                ),
              ),
              color: Colors.white, // Background color of the Card
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors
                            .grey[900], // Background color of the top section
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_movies,
                                size: 30.0,
                                color: Colors.white, // Color of the movie icon
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${ticket['ticket_code']}',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    _buildTicketInfo('Movie: ${ticket['movie_title']}'),
                    _buildTicketInfo('Release Date: ${ticket['release_date']}'),
                    _buildTicketInfo('Show Time: ${ticket['show_time']}'),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to movie details page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(
                              movieId: movieId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow
                            .shade700, // Set the background color to yellow
                        foregroundColor:
                            Colors.white, // Set the text color to white
                        minimumSize: Size(double.infinity,
                            40), // Make the button width fit the screen, adjust height
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Optional: add some rounded corners
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0), // Adjust vertical padding
                      ),
                      child: Text('View Movie'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTicketInfo(String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        info,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black87, // Color of the ticket information
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTickets() async {
    final userEmail = _appProvider.userEmail;
    if (userEmail == null) return [];

    final db = await _dbConnect.database;
    final List<Map<String, dynamic>> tickets = await db.rawQuery(
      'SELECT e_tickets.*, transactions.movie_id, movies.title AS movie_title, '
      'movies.release_date, movies.show_time '
      'FROM e_tickets '
      'INNER JOIN transactions ON e_tickets.transaction_id = transactions.id '
      'INNER JOIN users ON transactions.user_id = users.id '
      'INNER JOIN movies ON transactions.movie_id = movies.id '
      'WHERE users.email = ?',
      [userEmail],
    );
    return tickets;
  }

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    final userEmail = _appProvider.userEmail; // Get user email from provider
    if (userEmail == null)
      return []; // If user email is null, return empty list

    final db = await _dbConnect.database;
    final List<Map<String, dynamic>> transactions = await db.rawQuery(
      'SELECT transactions.id AS transaction_id, transactions.transaction_date, '
      'movies.title AS movie_name, COUNT(e_tickets.id) AS total_tickets, '
      'SUM(movies.ticket_price) AS total_price '
      'FROM transactions '
      'INNER JOIN users ON transactions.user_id = users.id '
      'INNER JOIN movies ON transactions.movie_id = movies.id '
      'LEFT JOIN e_tickets ON transactions.id = e_tickets.transaction_id '
      'WHERE users.email = ? '
      'GROUP BY transactions.id',
      [userEmail],
    );
    return transactions;
  }
}
