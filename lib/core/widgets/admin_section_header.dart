import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../theme/admin_text_styles.dart';

/// A section title above a group of cards/tables. Extracted from
/// analytics_page.dart — reusable anywhere a page groups content under a
/// labeled heading (Suppliers, Loyalty, etc.), instead of every page
/// writing its own `Text(..., style: sectionTitle)` + spacing.
class AdminSectionHeader extends StatelessWidget {
  final String title;

  const AdminSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminConstants.spacingSm),
      child: Text(title, style: AdminTextStyles.sectionTitle),
    );
  }
}