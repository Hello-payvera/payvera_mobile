import 'package:flutter/material.dart';

import '../../core/theme/colors/app_colors.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Transaction Details")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),

          const SizedBox(height: 20),

          Center(
            child: Text(
              "₦${transaction['amount']}",
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 30),

          _tile("Reference", transaction["reference"]),
          _tile("Status", transaction["status"]),
          _tile("Type", transaction["type"]),
          _tile("Date", transaction["createdAt"].toString()),
          _tile("Description", transaction["description"]),

          const SizedBox(height: 40),

          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text("Share Receipt"),
          ),
        ],
      ),
    );
  }

  Widget _tile(String title, dynamic value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(value?.toString() ?? "-"),
    );
  }
}
