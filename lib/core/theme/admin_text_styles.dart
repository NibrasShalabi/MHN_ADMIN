import 'package:flutter/material.dart';

import 'admin_colors.dart';

/// Dashboard type scale.
///
/// Smaller than the app's: a table row and a form label need to fit a lot
/// on screen, and heading sizes tuned for a phone waste a monitor.
class AdminTextStyles {
  AdminTextStyles._();

  static const String _fontFamily = 'Tajawal';

  static const TextStyle pageTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AdminColors.gold,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AdminColors.gold,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    color: AdminColors.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AdminColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    color: AdminColors.textSecondary,
  );

  /// Table headers — uppercase-ish weight and spacing so the header row
  /// reads as structure, not as another row of data.
  static const TextStyle tableHeader = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AdminColors.textSecondary,
    letterSpacing: 0.6,
  );
}