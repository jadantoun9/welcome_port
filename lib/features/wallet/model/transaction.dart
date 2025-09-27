class Transaction {
  String description;
  double amount;
  String amountFormatted;
  double balance;
  String balanceFormatted;
  String dateAdded;

  Transaction({
    required this.amount,
    required this.amountFormatted,
    required this.balance,
    required this.balanceFormatted,
    required this.dateAdded,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      amountFormatted: json['amount_formatted'] ?? '',
      balance: double.tryParse(json['balance'].toString()) ?? 0,
      balanceFormatted: json['balance_formatted'] ?? '',
      dateAdded: json['date_added'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
