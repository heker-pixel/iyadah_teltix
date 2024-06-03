import '../../../utils/db_connect.dart';
import './transaction_model.dart';
import 'ticket_controller.dart';

class TransactionController {
  final DBConnect _dbConnect = DBConnect();
  final TicketController _ticketController = TicketController();
  Future<List<Transaction>> getAllTransactions() async {
    final List<Map<String, dynamic>> transactionsData =
        await _dbConnect.queryAll('transactions');
    return transactionsData.map((data) => Transaction.fromJson(data)).toList();
  }

  Future<int> createTransaction(Map<String, dynamic> transactionData,
      int ticketCount, String ticketCodePrefix) async {
    final db = await _dbConnect.database;
    final transactionId = await db.insert('transactions', transactionData);

    // Generate e-tickets
    for (int i = 0; i < ticketCount; i++) {
      final ticketCode =
          '$ticketCodePrefix${DateTime.now().millisecondsSinceEpoch}-$i';
      await _ticketController.createETicket(transactionId, ticketCode);
    }

    final movieId = transactionData['movie_id'];
    await db.rawUpdate(
        'UPDATE movies SET ticket_count = ticket_count - ? WHERE id = ?',
        [ticketCount, movieId]);

    return transactionId;
  }

  Future<void> deleteTransaction(int transactionId) async {
    final db = await _dbConnect.database;
    await db
        .delete('transactions', where: 'id = ?', whereArgs: [transactionId]);
  }

  Future<List<Map<String, dynamic>>> getETicketsForTransaction(
      int transactionId) async {
    return await _ticketController.getETicketsForTransaction(transactionId);
  }
}
