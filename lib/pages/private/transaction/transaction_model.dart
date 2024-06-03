class Transaction {
  final int id;
  final int userId;
  final int movieId;
  final String transactionDate;
  final int totalAmount;
  final int totalPrice;

  Transaction({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.transactionDate,
    required this.totalAmount,
    required this.totalPrice,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      movieId: json['movie_id'],
      transactionDate: json['transaction_date'],
      totalAmount: json['total_amount'],
      totalPrice: json['total_price'],
    );
  }
}
