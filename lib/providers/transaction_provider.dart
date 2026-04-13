import 'package:flutter/foundation.dart';

import '../models/transaction.dart' as models;
import '../models/transaction_item.dart';
import '../services/database_service.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<models.Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<models.Transaction> get transactions =>
      List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransactions({String? cashierUsername}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _databaseService.getAllTransactions(
        cashierUsername: cashierUsername,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchTransactions({
    String? query,
    String? cashierUsername,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _databaseService.getAllTransactions(
        cashierUsername: cashierUsername,
        startDate: startDate,
        endDate: endDate,
        searchQuery: query,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<TransactionItem>> getTransactionItems(
      String transactionId) async {
    try {
      return await _databaseService.getTransactionItems(transactionId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<models.Transaction?> getTransactionById(String id) async {
    try {
      return await _databaseService.getTransactionById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
