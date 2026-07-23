import 'package:flutter/material.dart';

import '../../core/theme/colors/app_colors.dart';
import 'fund_wallet_screen.dart';

class PaymentMethodScreen extends StatelessWidget {
  final double amount;

  const PaymentMethodScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Method")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text("Paystack"),
                subtitle: Text("Fund ₦${amount.toStringAsFixed(2)}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FundWalletScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey.shade100,
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text("Flutterwave"),
                subtitle: const Text("Coming Soon"),
                enabled: false,
              ),
            ),
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FundWalletScreen()),
                );
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
