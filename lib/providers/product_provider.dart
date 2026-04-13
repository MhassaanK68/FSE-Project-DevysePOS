import 'package:flutter/foundation.dart';

import '../models/combo_item.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _lastActiveOnlyFilter = true;

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts({bool activeOnly = true}) async {
    _isLoading = true;
    _error = null;
    _lastActiveOnlyFilter = activeOnly;
    notifyListeners();

    try {
      _products = await _databaseService.getAllProducts(activeOnly: activeOnly);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductsByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _databaseService.getProductsByCategory(category);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInactiveProducts() async {
    _isLoading = true;
    _error = null;
    _lastActiveOnlyFilter = false;
    notifyListeners();

    try {
      _products = await _databaseService.getAllProducts(activeOnly: false);
      _products = _products.where((p) => !p.isActive).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      await _databaseService.insertProduct(product);
      await loadProducts(activeOnly: _lastActiveOnlyFilter);
      return true;
    } catch (e) {
      _error = _mapProductError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      await _databaseService.updateProduct(product);
      await loadProducts(activeOnly: _lastActiveOnlyFilter);
      return true;
    } catch (e) {
      _error = _mapProductError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _databaseService.deactivateProduct(id);
      await loadProducts(activeOnly: false);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> reactivateProduct(String id) async {
    try {
      await _databaseService.reactivateProduct(id);
      await loadProducts(activeOnly: false);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Combo products
  // ---------------------------------------------------------------------------

  Future<bool> addComboProduct(Product combo, List<ComboItem> items) async {
    try {
      await _databaseService.insertComboWithItems(combo, items);
      await loadProducts(activeOnly: _lastActiveOnlyFilter);
      return true;
    } catch (e) {
      _error = _mapProductError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateComboProduct(Product combo, List<ComboItem> items) async {
    try {
      await _databaseService.updateComboWithItems(combo, items);
      await loadProducts(activeOnly: _lastActiveOnlyFilter);
      return true;
    } catch (e) {
      _error = _mapProductError(e);
      notifyListeners();
      return false;
    }
  }

  Future<List<ComboItem>> getComboItems(String comboProductId) async {
    try {
      return await _databaseService.getComboItems(comboProductId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  String _mapProductError(Object e) {
    final errorMessage = e.toString();
    if (errorMessage.contains('UNIQUE constraint') ||
        errorMessage.contains('1555') ||
        errorMessage.contains('PRIMARYKEY')) {
      return 'This product could not be saved. Please try again.';
    } else if (errorMessage.contains('FOREIGN KEY')) {
      return 'Invalid product data. Please check the product details.';
    } else if (errorMessage.contains('NOT NULL')) {
      return 'Please fill in all required fields.';
    }
    return 'Failed to save product. Please try again.';
  }
}
