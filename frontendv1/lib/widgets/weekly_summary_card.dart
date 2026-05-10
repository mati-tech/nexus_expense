import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class WeeklySummaryCard extends StatelessWidget {
  final WeeklySummary? summary;

  const WeeklySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final spent = summary?.spent ?? 0;
    final earned = summary?.earned ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryHalf(
                label: 'Earned this week',
                value: earned,
                color: AppColors.income,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.divider),
            Expanded(
              child: _SummaryHalf(
                label: 'Spent this week',
                value: spent,
                color: AppColors.expense,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHalf extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _SummaryHalf({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          formatCurrency(value),
          style: TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
