import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const background = Color(0xFF1A1D1C);
  static const backgroundTop = Color(0xFF222725);
  static const backgroundBottom = Color(0xFF171917);
  static const panel = Color(0xFF1E2322);
  static const panelRaised = Color(0xFF202524);
  static const panelInset = Color(0xFF191C1B);
  static const field = Color(0xFF2B2F2D);
  static const border = Colors.white10;
  static const primary = Color(0xFF87C84C);
  static const primaryFocus = Color(0xFF87C95A);
  static const text = Color(0xFFF6F2E8);
  static const textDark = Color(0xFF23211D);
}

class AppRadii {
  const AppRadii._();

  static const panel = 26.0;
  static const section = 18.0;
  static const control = 16.0;
  static const input = 12.0;
}

BoxDecoration panelDecoration({
  Color color = AppColors.panel,
  double radius = AppRadii.panel,
}) {
  return BoxDecoration(
    color: color.withValues(alpha: 0.98),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.border),
    boxShadow: const [
      BoxShadow(
        blurRadius: 36,
        color: Color(0x33000000),
        offset: Offset(0, 18),
      ),
    ],
  );
}
