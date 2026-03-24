import 'package:flutter/foundation.dart';

import '../models/category.dart' as models;
import '../services/database_service.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _lastActiveOnlyFilter = true;

  List<models.Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories({bool activeOnly = true}) async {
    _isLoading = true;
    _error = null;
    _lastActiveOnlyFilter = activeOnly;
    notifyListeners();

    try {
      _categories = await _databaseService.getAllCategories(
        activeOnly: activeOnly,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInactiveCategories() async {
    _isLoading = true;
    _error = null;
    _lastActiveOnlyFilter = false;
    notifyListeners();

    try {
      _categories = await _databaseService.getAllCategories(activeOnly: false);
      _categories = _categories.where((c) => !c.isActive).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(models.Category category) async {
    try {
      await _databaseService.insertCategory(category);
      await loadCategories(activeOnly: _lastActiveOnlyFilter);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(models.Category category) async {
    try {
      await _databaseService.updateCategory(category);
      await loadCategories(activeOnly: _lastActiveOnlyFilter);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _databaseService.deactivateCategory(id);
      await loadCategories(activeOnly: _lastActiveOnlyFilter);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> reactivateCategory(String id) async {
    try {
      await _databaseService.reactivateCategory(id);
      await loadCategories(activeOnly: _lastActiveOnlyFilter);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<int> getProductCountForCategory(String categoryName) async {
    try {
      return await _databaseService.getProductCountForCategory(categoryName);
    } catch (e) {
      return 0;
    }
  }
}
