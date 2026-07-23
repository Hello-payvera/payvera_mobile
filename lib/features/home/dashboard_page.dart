import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/design/app_spacing.dart';
import '../../core/theme/colors/app_colors.dart';
import '../../core/theme/typography/app_typography.dart';

import '../../services/firestore_service.dart';

import 'widgets/header.dart';
import 'widgets/wallet_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_activity.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirestoreService firestore = FirestoreService();

  final User? currentUser = FirebaseAuth.instance.currentUser;

  bool loading = true;
  bool showBalance = true;

  String fullName = "";
  String payveraId = "";
  String walletId = "";

  double balance = 0;

  String currency = "NGN";

  Stream<DocumentSnapshot<Map<String, dynamic>>>? walletStream;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    if (currentUser == null) {
      setState(() => loading = false);
      return;
    }

    final profile = await firestore.getUserProfile(currentUser!.uid);

    final data = profile.data();

    if (data == null) {
      setState(() => loading = false);
      return;
    }

    fullName = data["fullName"] ?? "";
    payveraId = data["payveraId"] ?? "";
    walletId = data["walletId"] ?? "";

    if (walletId.isNotEmpty) {
      walletStream = firestore.watchWallet(walletId);

      final wallet = await firestore.getWallet(walletId);

      final walletData = wallet.data();

      if (walletData != null) {
        balance = (walletData["availableBalance"] ?? walletData["balance"] ?? 0)
            .toDouble();

        currency = walletData["currency"] ?? "NGN";
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  String get firstName {
    if (fullName.trim().isEmpty) {
      return "User";
    }

    return fullName.split(" ").first;
  }

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good morning";
    }

    if (hour < 17) {
      return "Good afternoon";
    }

    return "Good evening";
  }

  String get formattedBalance {
    if (!showBalance) {
      return "••••••••";
    }

    if (currency == "NGN") {
      return "₦${balance.toStringAsFixed(2)}";
    }

    return "$currency ${balance.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadDashboard,
        color: AppColors.secondary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(greeting: greeting, name: firstName),

              const SizedBox(height: AppSpacing.xxl),

              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: walletStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    final wallet = snapshot.data!.data()!;

                    balance = (wallet["availableBalance"] ?? 0).toDouble();

                    currency = wallet["currency"] ?? "NGN";
                  }

                  return WalletCard(
                    balance: formattedBalance,
                    payveraId: payveraId,
                    showBalance: showBalance,
                    onToggleBalance: () {
                      setState(() {
                        showBalance = !showBalance;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              const Text("Quick Actions", style: AppTypography.title),

              const SizedBox(height: AppSpacing.lg),

              const QuickActions(),

              const SizedBox(height: AppSpacing.xxl),

              Row(
                children: const [
                  Expanded(
                    child: Text("Recent Activity", style: AppTypography.title),
                  ),
                  Text(
                    "Live",
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              RecentActivity(walletId: walletId),
            ],
          ),
        ),
      ),
    );
  }
}
