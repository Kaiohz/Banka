class BankaTransaction {
  final int id;
  final String type;
  final String category;
  final int paymentDate;
  final int amount;

  const BankaTransaction({
    required this.id,
    required this.type,
    required this.category,
    required this.paymentDate,
    required this.amount,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'paymentDate': paymentDate,
      'amount': amount
    };
  }

  @override
  String toString() {
    return 'Transaction : { id : $id, type: $type, category : $category, paymentDate : $paymentDate, amount : $amount}';
  }
}
