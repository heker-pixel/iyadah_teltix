import 'package:flutter/material.dart';
import '../../utils/db_connect.dart'; // Import your DBConnect class
import '../utils/app_provider.dart'; // Import your AppProvider class

class TicketPage extends StatelessWidget {
  final DBConnect _dbConnect = DBConnect();
  final AppProvider _appProvider = AppProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated Tickets'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tickets found.'));
          }

          final tickets = snapshot.data!;
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return ListTile(
                title: Text('Ticket ID: ${ticket['id']}'),
                subtitle: Text('Ticket Code: ${ticket['ticket_code']}'),
                // Add more details if needed
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTickets() async {
    final userEmail = _appProvider.userEmail; // Get user email from provider
    if (userEmail == null)
      return []; // If user email is null, return empty list

    // Query tickets based on user email
    final db = await _dbConnect.database;
    final List<Map<String, dynamic>> tickets = await db.rawQuery(
      'SELECT e_tickets.* FROM e_tickets '
      'INNER JOIN transactions ON e_tickets.transaction_id = transactions.id '
      'INNER JOIN users ON transactions.user_id = users.id '
      'WHERE users.email = ?',
      [userEmail],
    );
    return tickets;
  }
}
