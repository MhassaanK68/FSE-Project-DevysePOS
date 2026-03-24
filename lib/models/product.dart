class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final String? imageUrl;
  final bool isActive;
  final String productType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.isActive = true,
    this.productType = 'regular',
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'is_active': isActive ? 1 : 0,
      'product_type': productType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      imageUrl: map['image_url'] as String?,
      isActive: (map['is_active'] as int) == 1,
      productType: map['product_type'] as String? ?? 'regular',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isActive,
    String? productType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    bool clearImageUrl = false,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      isActive: isActive ?? this.isActive,
      productType: productType ?? this.productType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
