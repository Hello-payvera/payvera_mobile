import 'package:flutter/material.dart';

import '../../core/theme/colors/app_colors.dart';

class AddMoneySuccessScreen extends StatelessWidget {
  final double amount;
  final String reference;

  const AddMoneySuccessScreen({
    super.key,
    required this.amount,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Payment Successful"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.green.shade100,
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 70,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Wallet Funded Successfully",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Text(
              "₦${amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                title: const Text("Reference"),
                subtitle: Text(reference),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Status"),
                subtitle: const Text("Successful"),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Back to Wallet"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
