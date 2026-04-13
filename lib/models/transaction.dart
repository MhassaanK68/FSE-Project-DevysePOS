class Transaction {
  final String id;
  final String transactionNumber;
  final String cashierUsername;
  final double subtotal;
  final double discountPercentage;
  final double discountAmount;
  final double total;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final int? itemCount;

  Transaction({
    required this.id,
    required this.transactionNumber,
    required this.cashierUsername,
    required this.subtotal,
    this.discountPercentage = 0,
    this.discountAmount = 0,
    required this.total,
    this.paymentMethod = 'cash',
    this.status = 'completed',
    required this.createdAt,
    this.itemCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'cashier_username': cashierUsername,
      'subtotal': subtotal,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'total': total,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      transactionNumber: map['transaction_number'] as String,
      cashierUsername: map['cashier_username'] as String,
      subtotal: (map['subtotal'] as num).toDouble(),
      discountPercentage: (map['discount_percentage'] as num?)?.toDouble() ?? 0,
      discountAmount: (map['discount_amount'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      status: map['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(map['created_at'] as String),
      itemCount: map['item_count'] as int?,
    );
  }

  Transaction copyWith({
    String? id,
    String? transactionNumber,
    String? cashierUsername,
    double? subtotal,
    double? discountPercentage,
    double? discountAmount,
    double? total,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    int? itemCount,
  }) {
    return Transaction(
      id: id ?? this.id,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      cashierUsername: cashierUsername ?? this.cashierUsername,
      subtotal: subtotal ?? this.subtotal,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}
