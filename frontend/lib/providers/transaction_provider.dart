import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiService api;
  final AuthProvider auth;

  List<TransactionGroup> _groups = const [];
  WeeklySummary? _weekly;
  bool _loading = false;
  String? _error;

  TransactionProvider({required this.api, required this.auth});

  List<TransactionGroup> get groups => _groups;
  WeeklySummary? get weekly => _weekly;
  bool get loading => _loading;
  String? get error => _error;
  bool get isEmpty => _groups.isEmpty;

  Future<void> refresh() async {
    if (!auth.isAuthenticated) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final groupsFuture = api.fetchTransactions();
      final summaryFuture = api.fetchWeeklySummary();
      final profileFuture = api.fetchProfile();
      _groups = await groupsFuture;
      _weekly = await summaryFuture;
      final AppUser refreshed = await profileFuture;
      auth.updateUser(refreshed);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Could not load data';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction({
    required String rawInput,
    required TransactionType type,
    String? note,
  }) async {
    await api.createTransaction(rawInput: rawInput, type: type, note: note);
    await refresh();
  }

  Future<void> removeTransaction(int id) async {
    await api.deleteTransaction(id);
    await refresh();
  }

  void clear() {
    _groups = const [];
    _weekly = null;
    _error = null;
    notifyListeners();
  }
}
