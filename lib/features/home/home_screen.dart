import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/app_radius.dart';
import '../../core/design/app_spacing.dart';
import '../../core/theme/colors/app_colors.dart';
import '../../core/theme/components/app_cards.dart';
import '../../core/theme/typography/app_typography.dart';
import '../../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final pages = const [
    _DashboardPage(),
    _SimplePage(title: 'Wallet', icon: AppIcons.wallet),
    _SimplePage(title: 'Scan', icon: AppIcons.qr),
    _SimplePage(title: 'Activity', icon: AppIcons.activity),
    _SimplePage(title: 'Profile', icon: AppIcons.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.secondary.withValues(alpha: 0.12),
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(AppIcons.home), label: 'Home'),
          NavigationDestination(icon: Icon(AppIcons.wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(AppIcons.qr), label: 'Scan'),
          NavigationDestination(icon: Icon(AppIcons.activity), label: 'Activity'),
          NavigationDestination(icon: Icon(AppIcons.profile), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatefulWidget {
  const _DashboardPage();

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  final firestoreService = FirestoreService();
  final currentUser = FirebaseAuth.instance.currentUser;

  bool isLoading = true;
  bool showBalance = true;

  String fullName = '';
  String payveraId = '';
  String walletId = '';
  double balance = 0.0;
  String currency = 'NGN';

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }

    final userDoc = await firestoreService.getUserProfile(currentUser!.uid);
    final userData = userDoc.data();

    if (userData == null) {
      setState(() => isLoading = false);
      return;
    }

    walletId = userData['walletId'] ?? '';
    fullName = userData['fullName'] ?? '';
    payveraId = userData['payveraId'] ?? '';

    if (walletId.isNotEmpty) {
      final walletDoc = await firestoreService.getWallet(walletId);
      final walletData = walletDoc.data();

      if (walletData != null) {
        balance = (walletData['balance'] ?? 0).toDouble();
        currency = walletData['currency'] ?? 'NGN';
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  String get firstName {
    if (fullName.trim().isEmpty) return 'User';
    return fullName.trim().split(' ').first;
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get formattedBalance {
    if (!showBalance) return '••••••';
    if (currency == 'NGN') return '₦${balance.toStringAsFixed(2)}';
    return '$currency ${balance.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(greeting: greeting, name: firstName),
              const SizedBox(height: AppSpacing.xxl),
              _WalletCard(
                balance: formattedBalance,
                payveraId: payveraId,
                showBalance: showBalance,
                onToggleBalance: () {
                  setState(() => showBalance = !showBalance);
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
              const Text('Quick Actions', style: AppTypography.title),
              const SizedBox(height: AppSpacing.lg),
              const _QuickActions(),
              const SizedBox(height: AppSpacing.xxl),
              const Text('Recent Activity', style: AppTypography.title),
              const SizedBox(height: AppSpacing.lg),
              const PayveraCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 44,
                      color: AppColors.secondary,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'No transactions yet',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your payments, transfers, and wallet activity will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.name});

  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/app_icon.png', height: 46, width: 46),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting,', style: AppTypography.label),
              Text(name, style: AppTypography.title),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
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
          colors: [
            AppColors.primary,
            Color(0xFF172554),
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.22),
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
                'PAYVERA WALLET',
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
                  showBalance
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(balance, style: AppTypography.money),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            payveraId.isEmpty ? '@payvera_user' : payveraId,
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Active Wallet',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      children: const [
        _ActionItem(title: 'Send', icon: AppIcons.send),
        _ActionItem(title: 'Receive', icon: AppIcons.receive),
        _ActionItem(title: 'Scan', icon: AppIcons.qr),
        _ActionItem(title: 'Fund', icon: Icons.add_card_rounded),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PayveraCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.secondary, size: 26),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimplePage extends StatelessWidget {
  const _SimplePage({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: PayveraCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.secondary, size: 72),
                const SizedBox(height: AppSpacing.lg),
                Text(title, style: AppTypography.title),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Coming soon',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}