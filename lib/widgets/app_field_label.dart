import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Small muted label used above form inputs.
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textLabel,
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
        height: 1.43,
      ),
    );
  }
}
