import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final bool isSmall;

  const LoadingWidget({super.key, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: isSmall ? 24 : 40,
        height: isSmall ? 24 : 40,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
