import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/transaction.dart' as models;
import '../models/transaction_item.dart';
import '../services/database_service.dart';
import '../utils/uuid_generator.dart';

class CartProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final List<CartItem> _items = [];
  double _discountPercentage = 0;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  double get discountPercentage => _discountPercentage;

  double get discountAmount => subtotal * _discountPercentage / 100;

  double get total => subtotal - discountAmount;

  void addItem(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity <= 1) {
        _items.removeAt(index);
      } else {
        _items[index].quantity--;
      }
      notifyListeners();
    }
  }

  void setDiscountPercentage(double percentage) {
    _discountPercentage = percentage.clamp(0, 100);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _discountPercentage = 0;
    notifyListeners();
  }

  Future<models.Transaction> processPayment({
    required String cashierUsername,
    String paymentMethod = 'cash',
  }) async {
    final transactionItems = _items.map((cartItem) {
      return TransactionItem(
        id: UUIDGenerator.generate(),
        transactionId: '',
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        productPrice: cartItem.product.price,
        quantity: cartItem.quantity,
        subtotal: cartItem.subtotal,
        createdAt: DateTime.now(),
      );
    }).toList();

    final transaction = await _databaseService.insertTransaction(
      cashierUsername: cashierUsername,
      subtotal: subtotal,
      discountPercentage: _discountPercentage,
      discountAmount: discountAmount,
      total: total,
      items: transactionItems,
      paymentMethod: paymentMethod,
    );

    clearCart();
    return transaction;
  }
}
