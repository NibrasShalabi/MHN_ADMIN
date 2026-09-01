import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_card.dart';

class AttentionCard extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onTap;

  const AttentionCard({super.key, required this.label, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isZero = count == 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
      child: AdminCard(
        padding: const EdgeInsets.all(AdminConstants.spacingMd),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isZero ? AdminColors.textDisabled.withValues(alpha: 0.15) : AdminColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: AdminTextStyles.label.copyWith(
                  color: isZero ? AdminColors.textDisabled : AdminColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AdminConstants.spacingMd),
            Expanded(child: Text(label, style: AdminTextStyles.body)),
            const Icon(Icons.arrow_back_ios_new, size: 14, color: AdminColors.textSecondary),
          ],
        ),
      ),
    );
  }
} 