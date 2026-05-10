import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final iconBg = isIncome ? AppColors.incomeSoft : AppColors.expenseSoft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : _categoryIcon(transaction.category),
              color: amountColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      transaction.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text(
                      '  •  ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      formatTime(transaction.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      transaction.note!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatSignedCurrency(transaction.amount, isIncome: isIncome),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Groceries':
        return Icons.local_grocery_store_outlined;
      case 'Food & Drink':
        return Icons.restaurant_outlined;
      case 'Transport':
        return Icons.directions_bus_outlined;
      case 'Entertainment':
        return Icons.movie_outlined;
      case 'Bills & Utilities':
        return Icons.receipt_long_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Health':
        return Icons.favorite_outline;
      case 'Income':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.payments_outlined;
    }
  }
}
