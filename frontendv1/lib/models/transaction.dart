enum TransactionType { income, expense }

extension TransactionTypeX on TransactionType {
  String get apiValue => this == TransactionType.income ? 'IN' : 'OUT';

  static TransactionType fromApi(String value) =>
      value == 'IN' ? TransactionType.income : TransactionType.expense;
}

class Transaction {
  final int id;
  final double amount;
  final String name;
  final String? note;
  final TransactionType type;
  final String category;
  final DateTime timestamp;

  const Transaction({
    required this.id,
    required this.amount,
    required this.name,
    required this.note,
    required this.type,
    required this.category,
    required this.timestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      amount: _toDouble(json['amount']),
      name: json['name'] as String,
      note: json['note'] as String?,
      type: TransactionTypeX.fromApi(json['type'] as String),
      category: json['category'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class TransactionGroup {
  final String label;
  final String dateIso;
  final List<Transaction> transactions;

  const TransactionGroup({
    required this.label,
    required this.dateIso,
    required this.transactions,
  });

  factory TransactionGroup.fromJson(Map<String, dynamic> json) {
    return TransactionGroup(
      label: json['label'] as String,
      dateIso: json['date_iso'] as String,
      transactions: (json['transactions'] as List)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WeeklySummary {
  final double spent;
  final double earned;
  final double net;
  final DateTime weekStart;
  final DateTime weekEnd;

  const WeeklySummary({
    required this.spent,
    required this.earned,
    required this.net,
    required this.weekStart,
    required this.weekEnd,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      spent: _toDouble(json['spent']),
      earned: _toDouble(json['earned']),
      net: _toDouble(json['net']),
      weekStart: DateTime.parse(json['week_start'] as String),
      weekEnd: DateTime.parse(json['week_end'] as String),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}
