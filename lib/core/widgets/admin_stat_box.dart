import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

/// A small label+value box — a mini KPI card. Extracted from
/// batch_details_panel.dart so any other panel needing the same "quick
/// stat" look (order count, total, etc.) reuses this instead of another
/// private copy.
class AdminStatBox extends StatelessWidget {
  final String label;
  final String value;

  const AdminStatBox({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminConstants.spacingSm),
      decoration: BoxDecoration(
        color: AdminColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: AdminTextStyles.body),
        ],
      ),
    );
  }
}