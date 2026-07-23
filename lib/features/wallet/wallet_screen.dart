import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/design/app_radius.dart';
import '../../core/design/app_spacing.dart';
import '../../core/theme/colors/app_colors.dart';
import '../../core/theme/components/app_cards.dart';
import '../../core/theme/typography/app_typography.dart';
import '../../services/firestore_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
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

  String formatBalance(String currency, double balance) {
    if (currency == 'NGN') {
      return '₦${balance.toStringAsFixed(2)}';
    }

    return '$currency ${balance.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final id = walletId;

    if (currentUser == null) {
      return const _WalletMessage(
        icon: Icons.lock_outline_rounded,
        title: 'Authentication required',
        message: 'Login to access your Payvera wallet.',
      );
    }

    if (id == null || id.isEmpty) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    return SafeArea(
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestoreService.watchWallet(id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _WalletMessage(
              icon: Icons.error_outline_rounded,
              title: 'Unable to load wallet',
              message: 'Please check your connection and try again.',
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          final walletData = snapshot.data?.data();

          if (walletData == null) {
            return const _WalletMessage(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wallet unavailable',
              message: 'We could not find a wallet for this account.',
            );
          }

          final availableBalance =
              (walletData['availableBalance'] ?? walletData['balance'] ?? 0)
                  .toDouble();

          final ledgerBalance =
              (walletData['ledgerBalance'] ?? walletData['balance'] ?? 0)
                  .toDouble();

          final currency = walletData['currency'] ?? 'NGN';
          final status = walletData['status'] ?? 'unknown';
          final isFrozen = walletData['isFrozen'] ?? false;

          return RefreshIndicator(
            color: AppColors.secondary,
            onRefresh: () async {
              await firestoreService.getWallet(id);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wallet', style: AppTypography.headline),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'View your balance and wallet status.',
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _BalanceCard(
                    balance: formatBalance(currency, availableBalance),
                    currency: currency,
                    status: status,
                    isFrozen: isFrozen,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Wallet Details', style: AppTypography.title),
                  const SizedBox(height: AppSpacing.lg),
                  PayveraCard(
                    child: Column(
                      children: [
                        _WalletDetailRow(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Available Balance',
                          value: formatBalance(currency, availableBalance),
                        ),
                        const Divider(height: 32),
                        _WalletDetailRow(
                          icon: Icons.menu_book_rounded,
                          label: 'Ledger Balance',
                          value: formatBalance(currency, ledgerBalance),
                        ),
                        const Divider(height: 32),
                        _WalletDetailRow(
                          icon: Icons.payments_outlined,
                          label: 'Currency',
                          value: currency,
                        ),
                        const Divider(height: 32),
                        _WalletDetailRow(
                          icon: Icons.verified_user_outlined,
                          label: 'Status',
                          value: isFrozen ? 'Frozen' : status.toUpperCase(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PayveraCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.security_rounded,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(
                          child: Text(
                            'Balance-changing operations will be processed securely by Payvera server-side services.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.currency,
    required this.status,
    required this.isFrozen,
  });

  final String balance;
  final String currency;
  final String status;
  final bool isFrozen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        borderRadius: AppRadius.extraLarge,
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF172554), AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVAILABLE BALANCE',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(balance, style: AppTypography.money),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Text(
                currency,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Icon(
                isFrozen ? Icons.lock_rounded : Icons.check_circle_rounded,
                color: isFrozen ? Colors.orangeAccent : Colors.white,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isFrozen ? 'Frozen' : status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletDetailRow extends StatelessWidget {
  const _WalletDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WalletMessage extends StatelessWidget {
  const _WalletMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
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
      ),
    );
  }
}
