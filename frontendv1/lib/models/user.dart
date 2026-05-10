class AppUser {
  final int id;
  final String username;
  final String nickname;
  final double currentBalance;

  const AppUser({
    required this.id,
    required this.username,
    required this.nickname,
    required this.currentBalance,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      currentBalance: _toDouble(json['current_balance']),
    );
  }

  AppUser copyWith({String? nickname, double? currentBalance}) {
    return AppUser(
      id: id,
      username: username,
      nickname: nickname ?? this.nickname,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}
