import 'package:flutter/material.dart';

import '../../core/theme/colors/app_colors.dart';
import 'payment_method_screen.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();

  final List<double> quickAmounts = const [500, 1000, 2000, 5000, 10000, 20000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _continue() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentMethodScreen(amount: amount)),
    );
  }

  Widget _amountChip(double amount) {
    return GestureDetector(
      onTap: () {
        _amountController.text = amount.toInt().toString();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.secondary),
        ),
        child: Text(
          "₦${amount.toInt()}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Money")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose Amount",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: quickAmounts.map(_amountChip).toList(),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Custom Amount",
                prefixText: "₦ ",
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: _continue,
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
