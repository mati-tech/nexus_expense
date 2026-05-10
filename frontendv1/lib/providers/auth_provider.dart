import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'nexus_token';
  static const _userIdKey = 'nexus_user_id';

  final ApiService api;

  AppUser? _user;
  String? _token;
  bool _bootstrapping = true;

  AuthProvider(this.api);

  AppUser? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _user != null;
  bool get bootstrapping => _bootstrapping;

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_tokenKey);
    if (stored != null) {
      api.setToken(stored);
      try {
        final user = await api.fetchProfile();
        _token = stored;
        _user = user;
      } catch (_) {
        await prefs.remove(_tokenKey);
        await prefs.remove(_userIdKey);
        api.setToken(null);
      }
    }
    _bootstrapping = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final result = await api.login(username: username, password: password);
    await _persist(result);
  }

  Future<void> signup({
    required String username,
    required String nickname,
    required String password,
    required double startingBalance,
  }) async {
    final result = await api.signup(
      username: username,
      nickname: nickname,
      password: password,
      startingBalance: startingBalance,
    );
    await _persist(result);
  }

  Future<void> _persist(AuthResult result) async {
    _token = result.token;
    _user = result.user;
    api.setToken(result.token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, result.token);
    await prefs.setInt(_userIdKey, result.user.id);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    notifyListeners();
  }

  void updateUser(AppUser user) {
    _user = user;
    notifyListeners();
  }
}
