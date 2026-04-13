class ComboItem {
  final String id;
  final String comboProductId;
  final String componentProductId;
  final int quantity;
  final DateTime createdAt;

  String? componentProductName;
  double? componentProductPrice;

  ComboItem({
    required this.id,
    required this.comboProductId,
    required this.componentProductId,
    this.quantity = 1,
    required this.createdAt,
    this.componentProductName,
    this.componentProductPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'combo_product_id': comboProductId,
      'component_product_id': componentProductId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ComboItem.fromMap(Map<String, dynamic> map) {
    return ComboItem(
      id: map['id'] as String,
      comboProductId: map['combo_product_id'] as String,
      componentProductId: map['component_product_id'] as String,
      quantity: map['quantity'] as int? ?? 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      componentProductName: map['component_product_name'] as String?,
      componentProductPrice:
          (map['component_product_price'] as num?)?.toDouble(),
    );
  }

  ComboItem copyWith({
    String? id,
    String? comboProductId,
    String? componentProductId,
    int? quantity,
    DateTime? createdAt,
  }) {
    return ComboItem(
      id: id ?? this.id,
      comboProductId: comboProductId ?? this.comboProductId,
      componentProductId: componentProductId ?? this.componentProductId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
