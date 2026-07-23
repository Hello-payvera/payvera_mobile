import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/design/app_spacing.dart';
import '../../../core/theme/colors/app_colors.dart';
import '../../../core/theme/components/app_cards.dart';
import '../../../models/transaction_model.dart';

class RecentTransactionTile extends StatelessWidget {
  const RecentTransactionTile({super.key, required this.transaction});

  final TransactionModel transaction;

  bool get isCredit => transaction.direction == TransactionDirection.credit;

  String get amountText {
    final prefix = isCredit ? "+" : "-";
    final currency = transaction.currency == "NGN" ? "₦" : transaction.currency;

    return "$prefix$currency${transaction.amount.toStringAsFixed(2)}";
  }

  String get timeLabel {
    if (transaction.createdAt == null) return "";

    return DateFormat("dd MMM • hh:mm a").format(transaction.createdAt!);
  }

  Color get statusColor {
    switch (transaction.status) {
      case TransactionStatus.successful:
        return AppColors.success;

      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return AppColors.error;

      case TransactionStatus.reversed:
        return AppColors.warning;

      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PayveraCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: .12),
            child: Icon(
              isCredit ? Icons.call_received_rounded : Icons.call_made_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isEmpty
                      ? transaction.type.name
                      : transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: TextStyle(
              color: isCredit ? AppColors.success : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
