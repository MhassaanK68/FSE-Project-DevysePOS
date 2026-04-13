class TransactionItem {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final double subtotal;
  final DateTime createdAt;

  TransactionItem({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.subtotal,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'quantity': quantity,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as String,
      transactionId: map['transaction_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      productPrice: (map['product_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      subtotal: (map['subtotal'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  TransactionItem copyWith({
    String? id,
    String? transactionId,
    String? productId,
    String? productName,
    double? productPrice,
    int? quantity,
    double? subtotal,
    DateTime? createdAt,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
