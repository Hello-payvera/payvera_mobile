import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/design/app_spacing.dart';
import '../../core/theme/colors/app_colors.dart';
import '../../core/theme/components/app_cards.dart';
import '../../core/theme/typography/app_typography.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final firestoreService = FirestoreService();
  final currentUser = FirebaseAuth.instance.currentUser;

  String? walletId;

  @override
  void initState() {
    super.initState();
    loadWalletId();
  }

  Future<void> loadWalletId() async {
    final user = currentUser;
    if (user == null) return;

    final userDoc = await firestoreService.getUserProfile(user.uid);
    final data = userDoc.data();

    if (!mounted) return;

    setState(() {
      walletId = data?['walletId'] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = walletId;

    if (id == null || id.isEmpty) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    return SafeArea(
      child: StreamBuilder<List<TransactionModel>>(
        stream: firestoreService.watchWalletTransactions(id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _ActivityMessage(
              icon: Icons.error_outline_rounded,
              title: 'Unable to load activity',
              message: 'Please check your connection and try again.',
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const _ActivityMessage(
              icon: Icons.receipt_long_rounded,
              title: 'No activity yet',
              message:
                  'Your transfers, wallet funding, QR payments, and refunds will appear here.',
            );
          }

          return SingleChildScrollView(
            padding: AppSpacing.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Activity', style: AppTypography.headline),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Track your Payvera wallet transactions.',
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.xxl),
                ...transactions.map(
                  (transaction) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _TransactionTile(transaction: transaction),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final TransactionModel transaction;

  bool get isCredit => transaction.direction == TransactionDirection.credit;

  String get amountText {
    final prefix = isCredit ? '+' : '-';
    final currency = transaction.currency == 'NGN' ? '₦' : transaction.currency;
    return '$prefix$currency${transaction.amount.toStringAsFixed(2)}';
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
      case TransactionStatus.initiated:
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return AppColors.secondary;
    }
  }

  IconData get icon {
    if (isCredit) return Icons.call_received_rounded;

    switch (transaction.type) {
      case TransactionType.qrPayment:
        return Icons.qr_code_scanner_rounded;
      case TransactionType.merchantPayment:
        return Icons.storefront_rounded;
      case TransactionType.billPayment:
        return Icons.receipt_long_rounded;
      case TransactionType.bankTransfer:
        return Icons.account_balance_rounded;
      case TransactionType.cardFunding:
        return Icons.credit_card_rounded;
      case TransactionType.refund:
      case TransactionType.reversal:
        return Icons.undo_rounded;
      case TransactionType.fee:
        return Icons.percent_rounded;
      case TransactionType.walletFunding:
      case TransactionType.walletTransfer:
      case TransactionType.payveraIdTransfer:
        return Icons.send_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PayveraCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.12),
            child: Icon(icon, color: statusColor),
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  transaction.status.name.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: TextStyle(
              color: isCredit ? AppColors.success : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityMessage extends StatelessWidget {
  const _ActivityMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.secondary),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTypography.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
