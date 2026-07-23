import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_money_success_screen.dart';
import '../../core/theme/colors/app_colors.dart';
import '../../services/paystack_service.dart';

class FundWalletScreen extends StatefulWidget {
  const FundWalletScreen({super.key});

  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen> {
  final _amountController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fundWallet() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a valid amount")));
      return;
    }

    final email = FirebaseAuth.instance.currentUser?.email ?? "";

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No email found")));
      return;
    }

    setState(() {
      loading = true;
    });

    final success = await PaystackService().fundWallet(
      context: context,
      email: email,
      amount: amount,
    );

    setState(() {
      loading = false;
    });

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AddMoneySuccessScreen(
            amount: amount,
            reference: DateTime.now().millisecondsSinceEpoch.toString(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Payment cancelled.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fund Wallet")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixText: "₦ ",
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: loading ? null : _fundWallet,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
