import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/format.dart';

/// Kartu ringkasan: total belanja, bar progres, dan sisa budget.
class BudgetBar extends StatelessWidget {
  const BudgetBar({super.key, required this.total, required this.budget});

  final int total;
  final int budget;

  @override
  Widget build(BuildContext context) {
    final over = total > budget;
    final color = over ? AppColors.accent : AppColors.success;
    final message = over
        ? 'Melebihi budget ${formatRupiah(total - budget)}'
        : 'Sisa budget ${formatRupiah(budget - total)} dari ${formatRupiah(budget)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total outfit', style: TextStyle(color: AppColors.muted)),
              Text(formatRupiah(total),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: budget == 0 ? 0 : (total / budget).clamp(0.0, 1.0),
              minHeight: 8,
              color: color,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
