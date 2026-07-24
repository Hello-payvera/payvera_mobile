import 'package:flutter/material.dart';

import '../../../models/beneficiary_model.dart';

class BeneficiaryTile extends StatelessWidget {
  final BeneficiaryModel beneficiary;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const BeneficiaryTile({
    super.key,
    required this.beneficiary,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          beneficiary.fullName.isEmpty
              ? '?'
              : beneficiary.fullName[0].toUpperCase(),
        ),
      ),
      title: Text(beneficiary.fullName),
      subtitle: Text(beneficiary.payveraId),
      trailing: IconButton(
        icon: Icon(
          beneficiary.favorite
              ? Icons.star
              : Icons.star_border,
          color: Colors.amber,
        ),
        onPressed: onFavorite,
      ),
      onTap: onTap,
    );
  }
}
