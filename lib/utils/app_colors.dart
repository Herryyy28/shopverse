import 'package:flutter/material.dart';

class AppColors {
  // ── Brand (Nexkart Blue/Indigo) ───────────────────────────────────────────
  static const Color primary = Color(0xFF5B61F4);        // Nexkart Blue-Indigo
  static const Color primaryDark = Color(0xFF4347D9);
  static const Color primaryLight = Color(0xFFEEEFFF);
  static const Color secondary = Color(0xFF8B5CF6);      // Purple accent
  static const Color accent = Color(0xFFFF6B35);         // Coral CTA
  static const Color accentGreen = Color(0xFF10B981);

  // ── Legacy / Keep for Blinkit sections ───────────────────────────────────
  static const Color brandRed = Color(0xFFFF3232);
  static const Color blinkitYellow = Color(0xFFFFC107);

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color backgroundColor = Color(0xFFF6F7FB);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // ── Soft UI ───────────────────────────────────────────────────────────────
  static const Color softBackground = Color(0xFFF0F2F5);
  static const Color softShadowLight = Colors.white;
  static const Color softShadowDark = Color(0xFFA3B1C6);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B61F4), Color(0xFF8B5CF6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
