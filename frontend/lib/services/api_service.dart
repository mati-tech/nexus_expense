import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/transaction.dart';
import '../models/user.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthResult {
  final String token;
  final AppUser user;
  AuthResult({required this.token, required this.user});
}

class ApiService {
  // Override at runtime via --dart-define=API_BASE_URL=https://...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://nexus-expense.onrender.com',
  );

  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> _headers({bool json = true}) {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (_token != null) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Never _throwFor(http.Response response) {
    String message;
    try {
      final body = jsonDecode(response.body);
      message = body is Map && body['detail'] != null
          ? body['detail'].toString()
          : 'Request failed (${response.statusCode})';
    } catch (_) {
      message = 'Request failed (${response.statusCode})';
    }
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<AuthResult> signup({
    required String username,
    required String nickname,
    required String password,
    required double startingBalance,
  }) async {
    final response = await http.post(
      _uri('/auth/signup'),
      headers: _headers(),
      body: jsonEncode({
        'username': username,
        'nickname': nickname,
        'password': password,
        'starting_balance': startingBalance,
      }),
    );
    if (response.statusCode != 201) _throwFor(response);
    return _parseAuth(response.body);
  }

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      _uri('/auth/login'),
      headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );
    if (response.statusCode != 200) _throwFor(response);
    return _parseAuth(response.body);
  }

  AuthResult _parseAuth(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    return AuthResult(
      token: data['access_token'] as String,
      user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<AppUser> fetchProfile() async {
    final response = await http.get(_uri('/user/profile'), headers: _headers());
    if (response.statusCode != 200) _throwFor(response);
    return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AppUser> updateBalance(double balance) async {
    final response = await http.put(
      _uri('/user/balance'),
      headers: _headers(),
      body: jsonEncode({'current_balance': balance}),
    );
    if (response.statusCode != 200) _throwFor(response);
    return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AppUser> updateNickname(String nickname) async {
    final response = await http.put(
      _uri('/user/nickname'),
      headers: _headers(),
      body: jsonEncode({'nickname': nickname}),
    );
    if (response.statusCode != 200) _throwFor(response);
    return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<TransactionGroup>> fetchTransactions() async {
    final response =
        await http.get(_uri('/transactions'), headers: _headers());
    if (response.statusCode != 200) _throwFor(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['groups'] as List)
        .map((e) => TransactionGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Transaction> createTransaction({
    required String rawInput,
    required TransactionType type,
    String? note,
  }) async {
    final response = await http.post(
      _uri('/transactions'),
      headers: _headers(),
      body: jsonEncode({
        'raw_input': rawInput,
        'type': type.apiValue,
        if (note != null && note.isNotEmpty) 'note': note,
      }),
    );
    if (response.statusCode != 201) _throwFor(response);
    return Transaction.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(int id) async {
    final response = await http.delete(
      _uri('/transactions/$id'),
      headers: _headers(),
    );
    if (response.statusCode != 204) _throwFor(response);
  }

  Future<WeeklySummary> fetchWeeklySummary() async {
    final response = await http.get(
      _uri('/transactions/summary/weekly'),
      headers: _headers(),
    );
    if (response.statusCode != 200) _throwFor(response);
    return WeeklySummary.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}
