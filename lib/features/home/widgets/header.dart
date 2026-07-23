import 'package:flutter/material.dart';

import '../../../core/design/app_spacing.dart';
import '../../../core/theme/typography/app_typography.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.greeting, required this.name});

  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset("assets/app_icon.png", width: 46, height: 46),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$greeting,", style: AppTypography.label),
              Text(name, style: AppTypography.title),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}
