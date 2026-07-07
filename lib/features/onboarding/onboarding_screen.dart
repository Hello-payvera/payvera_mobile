import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/app_radius.dart';
import '../../core/design/app_spacing.dart';
import '../../core/theme/colors/app_colors.dart';
import '../../core/theme/components/app_buttons.dart';
import '../../core/theme/typography/app_typography.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final pageController = PageController();
  int currentPage = 0;

  final pages = const [
    _OnboardingData(
      icon: AppIcons.wallet,
      title: 'The Future of Money Starts Here',
      subtitle:
          'Send, receive, save, and manage your money with a wallet built for a borderless world.',
    ),
    _OnboardingData(
      icon: Icons.account_balance_rounded,
      title: 'Connect Banks and Cards',
      subtitle:
          'Link your bank accounts and cards securely to fund your wallet and move money faster.',
    ),
    _OnboardingData(
      icon: AppIcons.qr,
      title: 'Pay Anyone, Anywhere',
      subtitle:
          'Use Payvera ID, QR codes, bank transfers, and merchant payments from one clean app.',
    ),
    _OnboardingData(
      icon: Icons.security_rounded,
      title: 'Security at the Core',
      subtitle:
          'Protect your account with PIN, biometrics, trusted devices, and smart verification.',
    ),
  ];

  void nextPage() {
    if (currentPage == pages.length - 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
  'assets/app_icon.png',
  height: 42,
  width: 42,
),
                  const SizedBox(width: AppSpacing.md),
                  const Text(
                    'PAYVERA',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() => currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = pages[index];

                    return _OnboardingPage(data: page);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: currentPage == index ? 28 : 8,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? AppColors.secondary
                          : AppColors.border,
                      borderRadius: AppRadius.small,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              PayveraButton(
                text: isLastPage ? 'Create Account' : 'Continue',
                onPressed: nextPage,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          height: 220,
          width: 220,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(48),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.18),
                blurRadius: 45,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.22),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: AppColors.gold.withValues(alpha: 0.16),
                ),
              ),
              Center(
                child: Icon(
                  data.icon,
                  size: 92,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: AppTypography.headline,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          data.subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.subtitle.copyWith(height: 1.55),
        ),
        const Spacer(),
      ],
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}