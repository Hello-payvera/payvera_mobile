import 'package:flutter/material.dart';

import '../../models/beneficiary_model.dart';
import '../../services/beneficiary_service.dart';
import 'widgets/beneficiary_tile.dart';

class BeneficiariesScreen extends StatelessWidget {
  const BeneficiariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = BeneficiaryService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiaries'),
      ),
      body: StreamBuilder<List<BeneficiaryModel>>(
        stream: service.recentBeneficiaries(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final beneficiaries = snapshot.data!;

          if (beneficiaries.isEmpty) {
            return const Center(
              child: Text(
                'No beneficiaries yet.',
              ),
            );
          }

          return ListView.builder(
            itemCount: beneficiaries.length,
            itemBuilder: (_, index) {
              final item = beneficiaries[index];

              return BeneficiaryTile(
                beneficiary: item,
                onTap: () {
                  Navigator.pop(context, item);
                },
                onFavorite: () {
                  service.toggleFavorite(
                    item.id,
                    !item.favorite,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
