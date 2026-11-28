import 'package:material_ui/material_ui.dart';
import 'package:trackpense/core/extensions/color_extensions.dart';
import 'package:trackpense/core/extensions/double_extensions.dart';
import 'package:trackpense/core/theme/app_colors.dart';

/// Summary of the loaded transactions: total income, total expense, and balance.
class SummaryBar extends StatelessWidget {
  const SummaryBar({
    super.key,
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  static const double _barHeight = 20;
  static const double _barRadius = 10;
  static const double _minForegroundWidth = 4;
  static const double _maxForegroundRatio = 0.96;

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;

    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProximityBar(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SummaryAmount(
                    label: 'Expenses',
                    value: expense,
                    color: AppColors.expense,
                  ),
                ),
                Expanded(
                  child: _SummaryAmount(
                    label: 'Income',
                    value: income,
                    color: AppColors.income,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Balance',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  balance.toCommaString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: balance >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bar showing which side dominates: the larger total fills the track in its
  /// light tint, and the smaller total is drawn as a foreground cap whose width
  /// is its share of the dominant total.
  Widget _buildProximityBar() {
    final safeExpense = expense.isFinite ? expense.clamp(0.0, double.infinity) : 0.0;
    final safeIncome = income.isFinite ? income.clamp(0.0, double.infinity) : 0.0;

    final isEqual = safeExpense == safeIncome;
    final isExpenseHigher = safeExpense > safeIncome;

    final Color backgroundColor;
    final Color foregroundColor;
    final Alignment alignment;
    final double ratio;

    if (isEqual) {
      backgroundColor = AppColors.grey500;
      foregroundColor = AppColors.grey500;
      alignment = Alignment.center;
      ratio = 1;
    } else if (isExpenseHigher) {
      backgroundColor = AppColors.expense.lighten(0.6);
      foregroundColor = AppColors.income;
      alignment = Alignment.centerRight;
      ratio = safeIncome / safeExpense;
    } else {
      backgroundColor = AppColors.income.lighten(0.6);
      foregroundColor = AppColors.expense;
      alignment = Alignment.centerLeft;
      ratio = safeExpense / safeIncome;
    }

    final percentage = (ratio * 100).toStringAsFixed(1);
    final tooltipMessage = isEqual
        ? 'Expenses equal income'
        : isExpenseHigher
        ? 'Income covers $percentage% of expenses'
        : 'Expenses consume $percentage% of income';

    return Tooltip(
      message: tooltipMessage,
      child: Semantics(
        label: tooltipMessage,
        child: LayoutBuilder(
          builder: (context, constraints) {
            var foregroundWidth = 0.0;
            if (isEqual) {
              foregroundWidth = constraints.maxWidth;
            } else if (ratio > 0) {
              foregroundWidth = constraints.maxWidth * ratio.clamp(0.0, _maxForegroundRatio);
              foregroundWidth = foregroundWidth.clamp(0.0, constraints.maxWidth);
              if (foregroundWidth > 0 && foregroundWidth < _minForegroundWidth) {
                foregroundWidth = _minForegroundWidth.clamp(0.0, constraints.maxWidth);
              }
            }

            return Container(
              width: double.infinity,
              height: _barHeight,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(_barRadius),
              ),
              child: isEqual || foregroundWidth == 0
                  ? null
                  : Align(
                      alignment: alignment,
                      child: SizedBox(
                        width: foregroundWidth,
                        height: _barHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: foregroundColor,
                            borderRadius: BorderRadius.horizontal(
                              left: isExpenseHigher ? const Radius.circular(999) : Radius.zero,
                              right: isExpenseHigher ? Radius.zero : const Radius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryAmount extends StatelessWidget {
  const _SummaryAmount({
    required this.label,
    required this.value,
    required this.color,
    this.textAlign = TextAlign.start,
  });

  final String label;
  final double value;
  final Color color;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value.toCommaString(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
