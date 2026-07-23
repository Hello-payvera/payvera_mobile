import 'package:flutter/material.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/app_radius.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/theme/colors/app_colors.dart';
import '../../../core/theme/components/app_cards.dart';

import '../../transfers/transfer_screen.dart';
import '../../wallet/fund_wallet_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: .88,
      children: [
        ActionItem(
          title: "Send",
          icon: AppIcons.send,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransferScreen()),
            );
          },
        ),
        const ActionItem(title: "Receive", icon: AppIcons.receive),
        const ActionItem(title: "Scan", icon: AppIcons.qr),
        ActionItem(
          title: "Fund",
          icon: Icons.add_card_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FundWalletScreen()),
            );
          },
        ),
      ],
    );
  }
}

class ActionItem extends StatelessWidget {
  const ActionItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: PayveraCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: AppColors.secondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
