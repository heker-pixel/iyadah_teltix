import '../../../utils/db_connect.dart';

class TicketController {
  final DBConnect _dbConnect = DBConnect();

  Future<int> createETicket(int transactionId, String ticketCode) async {
    final db = await _dbConnect.database;
    return await db.insert('e_tickets',
        {'transaction_id': transactionId, 'ticket_code': ticketCode});
  }

  Future<List<Map<String, dynamic>>> getETicketsForTransaction(
      int transactionId) async {
    final db = await _dbConnect.database;
    return await db.query('e_tickets',
        where: 'transaction_id = ?', whereArgs: [transactionId]);
  }
}
