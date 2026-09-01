import 'package:flutter/material.dart';

/// Dashboard palette.
///
/// Shares the brand's wine and gold, but deliberately calmer than the
/// shop's: this is a screen someone works on for hours, so the fire
/// gradients are gone, the background is lifted off pure black, and
/// contrast is tuned for dense tables rather than for display.
class AdminColors {
  AdminColors._();

  // Surfaces — layered greys so tables, cards and the shell separate
  // without needing borders everywhere.
  static const Color canvas = Color(0xFF15100F); // page background
  static const Color surface = Color(0xFF1D1716); // cards, panels
  static const Color surfaceRaised = Color(0xFF251E1C); // table headers, hover
  static const Color sidebar = Color(0xFF120D0C);
  static const Color border = Color(0xFF362B29);

  // Brand
  static const Color primary = Color(0xFFA81419);
  static const Color primaryDark = Color(0xFF7A0C10);
  static const Color gold = Color(0xFFDE9A34);
  static const Color goldDark = Color(0xFF7A4A10);

  // Text — no pure white, same rule as the app
  static const Color textPrimary = Color(0xFFE3DCDA);
  static const Color textSecondary = Color(0xFFA1938F);
  static const Color textDisabled = Color(0xFF6B605D);

  // Semantic — used on status chips, so they must stay legible at caption size
  static const Color success = Color(0xFF4C9068);
  static const Color warning = Color(0xFFD9A03C);
  static const Color danger = Color(0xFFD9534F);
  static const Color info = Color(0xFF5390A8);
}