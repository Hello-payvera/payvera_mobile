import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/theme/colors/app_colors.dart';
import '../../../core/theme/components/app_buttons.dart';
import '../../../core/theme/components/app_input.dart';
import '../../../core/theme/typography/app_typography.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authService = AuthService();
  final firestoreService = FirestoreService();

  bool isLoading = false;

  Future<void> registerUser() async {
    if (fullNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        await firestoreService.createUserProfile(
          uid: user.uid,
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
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

              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 70,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              Text(
                'Create your account',
                style: AppTypography.headline,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Start your secure digital wallet journey with Payvera.',
                style: AppTypography.subtitle,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              PayveraTextField(
                controller: fullNameController,
                label: 'Full Name',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),

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

              const SizedBox(height: AppSpacing.xxl),

              PayveraButton(
                text: 'Create Account',
                icon: AppIcons.wallet,
                isLoading: isLoading,
                onPressed: registerUser,
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: AppTypography.subtitle.copyWith(fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Login'),
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