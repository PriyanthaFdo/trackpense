import 'package:flutter/material.dart';
import 'package:trackpense/core/extensions/color_extension.dart';
import 'package:trackpense/core/extensions/datetime_extension.dart';
import 'package:trackpense/core/extensions/double_extension.dart';
import 'package:trackpense/data/constants/kjp_colors.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.date,
    required this.description,
    required this.amount,
    required this.onTap,
    required this.isExpense,
  });

  final DateTime date;
  final String description;
  final double amount;
  final VoidCallback onTap;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isExpense ? KjpColors.expense.lighten(0.8) : KjpColors.income.lighten(0.8),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    date.format(format: 'E'),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    date.format(format: 'dd'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      height: 0.7,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.format(format: 'MMMM'),
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date.format(format: 'hh:mm a'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(description),
                ],
              ),
              const Spacer(),
              Center(
                child: Text(amount.toCommaString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
