import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/theme/colors/app_colors.dart';
import '../activity/activity_screen.dart';
import '../wallet/wallet_screen.dart';
import 'dashboard_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    WalletScreen(),
    _PlaceholderPage(title: 'Scan', icon: AppIcons.qr),
    ActivityScreen(),
    _PlaceholderPage(title: 'Profile', icon: AppIcons.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        indicatorColor: AppColors.secondary.withValues(alpha: .15),
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(AppIcons.home), label: 'Home'),
          NavigationDestination(icon: Icon(AppIcons.wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(AppIcons.qr), label: 'Scan'),
          NavigationDestination(
            icon: Icon(AppIcons.activity),
            label: 'Activity',
          ),
          NavigationDestination(icon: Icon(AppIcons.profile), label: 'Profile'),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderPage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
