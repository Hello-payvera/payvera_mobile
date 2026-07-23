import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/theme/colors/app_colors.dart';
import '../../../core/theme/components/app_buttons.dart';
import '../../../core/theme/components/app_input.dart';
import '../../../core/theme/typography/app_typography.dart';
import '../../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authService = AuthService();

  bool isLoading = false;
  bool rememberDevice = true;

  Future<void> loginUser() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter your email first')));
      return;
    }

    await authService.resetPassword(emailController.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(child: Image.asset('assets/logo.png', height: 70)),
              const SizedBox(height: AppSpacing.xxxl),
              Text('Welcome back', style: AppTypography.headline),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Login securely and continue managing your Payvera wallet.',
                style: AppTypography.subtitle,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              PayveraTextField(
                controller: emailController,
                label: 'Email Address',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.lg),
              PayveraTextField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_rounded,
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Checkbox(
                    value: rememberDevice,
                    activeColor: AppColors.secondary,
                    onChanged: (value) {
                      setState(() => rememberDevice = value ?? true);
                    },
                  ),
                  const Text('Remember this device'),
                  const Spacer(),
                  TextButton(
                    onPressed: resetPassword,
                    child: const Text('Forgot?'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              PayveraButton(
                text: 'Login',
                icon: AppIcons.wallet,
                isLoading: isLoading,
                onPressed: loginUser,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to Payvera?',
                    style: AppTypography.subtitle.copyWith(fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Create Account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
