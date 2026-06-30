import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  setState(() => isLoading = true);

  try {
    debugPrint("========== REGISTER REQUEST ==========");
    debugPrint("Name: ${fullNameController.text}");
    debugPrint("Email: ${emailController.text}");
    debugPrint("Password Length: ${passwordController.text.length}");

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Registration Successful 🎉"),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  } on FirebaseAuthException catch (e) {
    debugPrint("========== FIREBASE ERROR ==========");
    debugPrint("Code: ${e.code}");
    debugPrint("Message: ${e.message}");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Error: ${e.code}\n${e.message}",
        ),
      ),
    );
  } catch (e) {
    debugPrint("========== UNKNOWN ERROR ==========");
    debugPrint(e.toString());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Unexpected Error:\n$e",
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
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
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green,
                  foregroundColor: AppTheme.white,
                ),
                onPressed: isLoading ? null : registerUser,
                child: isLoading
                    ? const CircularProgressIndicator(color: AppTheme.white)
                    : const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}