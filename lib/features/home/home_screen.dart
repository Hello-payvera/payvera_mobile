import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
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
    _SimplePage(title: 'Wallet', icon: Icons.account_balance_wallet),
    _SimplePage(title: 'QR Payments', icon: Icons.qr_code_scanner),
    _SimplePage(title: 'Merchant', icon: Icons.storefront),
    _SimplePage(title: 'Profile', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'QR'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Merchant'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  String get firstName {
    if (fullName.trim().isEmpty) return 'User';
    return fullName.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.green),
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadDashboardData,
        color: AppTheme.green,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $firstName 👋',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                payveraId.isEmpty ? 'Welcome to Payvera' : payveraId,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wallet Balance',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currency == 'NGN'
                          ? '₦${balance.toStringAsFixed(2)}'
                          : '$currency ${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fast. Secure. Borderless.',
                      style: TextStyle(color: AppTheme.gold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: const [
                  _ActionCard(title: 'Send', icon: Icons.send),
                  _ActionCard(title: 'Receive', icon: Icons.call_received),
                  _ActionCard(title: 'Scan QR', icon: Icons.qr_code_scanner),
                  _ActionCard(title: 'Pay Bills', icon: Icons.receipt_long),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.green.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.green, size: 34),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.green, size: 70),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Coming soon'),
          ],
        ),
      ),
    );
  }
}