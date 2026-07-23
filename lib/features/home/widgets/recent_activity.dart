import 'package:flutter/material.dart';

import '../../../core/design/app_spacing.dart';
import '../../../core/theme/colors/app_colors.dart';
import '../../../core/theme/components/app_cards.dart';
import '../../../models/transaction_model.dart';
import '../../../services/firestore_service.dart';

import 'recent_transaction_tile.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key, required this.walletId});

  final String walletId;

  @override
  Widget build(BuildContext context) {
    if (walletId.isEmpty) {
      return const PayveraCard(
        child: Text(
          "Wallet loading...",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final service = FirestoreService();

    return StreamBuilder<List<TransactionModel>>(
      stream: service.watchWalletTransactions(walletId, limit: 3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const PayveraCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const PayveraCard(child: Text("Unable to load activity."));
        }

        final txs = snapshot.data ?? [];

        if (txs.isEmpty) {
          return const PayveraCard(
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 46, color: AppColors.secondary),
                SizedBox(height: AppSpacing.md),
                Text(
                  "No transactions yet",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        return Column(
          children: txs
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: RecentTransactionTile(transaction: e),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
