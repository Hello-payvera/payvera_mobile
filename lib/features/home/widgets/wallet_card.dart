import 'package:flutter/material.dart';

import '../../../core/design/app_radius.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/theme/colors/app_colors.dart';
import '../../../core/theme/typography/app_typography.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.balance,
    required this.payveraId,
    required this.showBalance,
    required this.onToggleBalance,
  });

  final String balance;
  final String payveraId;
  final bool showBalance;
  final VoidCallback onToggleBalance;

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
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: .22),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "PAYVERA WALLET",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onToggleBalance,
                icon: Icon(
                  showBalance ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            "Available Balance",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(balance, style: AppTypography.money),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            payveraId.isEmpty ? "@payvera_user" : payveraId,
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text("Active Wallet", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
