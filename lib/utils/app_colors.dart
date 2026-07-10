import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Core ───────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF5B61F4);
  static const Color primaryDark = Color(0xFF4347D9);
  static const Color primaryLight = Color(0xFFEEEFFF);
  static const Color secondary = Color(0xFF8B5CF6);

  // ── Accent / CTA ─────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFFF0EB);
  static const Color accentGreen = Color(0xFF00C48C);
  static const Color accentGreenLight = Color(0xFFE6FAF5);

  // ── Quick-commerce Highlights ────────────────────────────────────────────
  static const Color brandRed = Color(0xFFFF3B30);
  static const Color brandRedLight = Color(0xFFFFEBEA);
  static const Color blinkitYellow = Color(0xFFFFC107);
  static const Color blinkitYellowLight = Color(0xFFFFF8E1);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00C48C);
  static const Color successLight = Color(0xFFE6FAF5);
  static const Color warning = Color(0xFFFFB300);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFFFEBEA);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);

  // ── Light Mode Surfaces ──────────────────────────────────────────────────
  static const Color backgroundColor = Color(0xFFF5F6FA);
  static const Color surfaceColor = Colors.white;
  static const Color surface2 = Color(0xFFF0F2F8);
  static const Color surface3 = Color(0xFFE8EBF5);
  static const Color cardColor = Colors.white;

  // ── Dark Mode Surfaces ───────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0D0E1A);
  static const Color darkSurface = Color(0xFF161728);
  static const Color darkSurface2 = Color(0xFF1E2035);
  static const Color darkCard = Color(0xFF1A1B2E);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF2D2F45);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B61F4), Color(0xFF8B5CF6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF4347D9), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00C48C), Color(0xFF00A36C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient promoGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Soft UI ───────────────────────────────────────────────────────────────
  static const Color softBackground = Color(0xFFF0F2F5);
  static const Color softShadowLight = Colors.white;
  static const Color softShadowDark = Color(0xFFA3B1C6);
}
