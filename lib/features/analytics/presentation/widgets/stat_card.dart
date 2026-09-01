import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_card.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const StatCard({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AdminTextStyles.caption),
          const SizedBox(height: AdminConstants.spacingXs),
          Text(
            value,
            style: AdminTextStyles.pageTitle.copyWith(color: valueColor ?? AdminColors.textPrimary),
          ),
        ],
      ),
    );
  }
}