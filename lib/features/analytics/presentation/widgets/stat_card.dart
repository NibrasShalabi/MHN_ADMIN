import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_card.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  /// Percent change vs the previous period — positive shows a green
  /// up-arrow, negative a red down-arrow, null hides the row entirely
  /// (there's no prior-period data to compare against yet).
  final double? trend;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final accent = valueColor ?? AdminColors.gold;

    return AdminCard(
      padding: const EdgeInsets.all(AdminConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AdminTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(AdminConstants.spacingXs),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                  ),
                  child: Icon(icon, size: 16, color: accent),
                ),
            ],
          ),
          const SizedBox(height: AdminConstants.spacingSm),
          Text(
            value,
            style: AdminTextStyles.pageTitle.copyWith(color: AdminColors.textPrimary),
          ),
          if (trend != null) ...[
            const SizedBox(height: AdminConstants.spacingXs),
            _TrendRow(trend: trend!),
          ],
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  final double trend;

  const _TrendRow({required this.trend});

  @override
  Widget build(BuildContext context) {
    final isUp = trend >= 0;
    final color = isUp ? AdminColors.success : AdminColors.danger;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          '${trend.abs().toStringAsFixed(0)}%',
          style: AdminTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}