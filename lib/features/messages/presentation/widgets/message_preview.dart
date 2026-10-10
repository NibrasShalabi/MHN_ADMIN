import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';

/// The message as the customer reads it: gold title over the body.
class MessagePreview extends StatelessWidget {
  final String title;
  final String body;
  final Widget? trailing;

  const MessagePreview({super.key, required this.title, required this.body, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminConstants.spacingMd),
      decoration: BoxDecoration(
        color: AdminColors.canvas,
        borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
        border: Border.all(color: AdminColors.gold.withValues(alpha: 0.4), width: AdminConstants.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(title, style: AdminTextStyles.label.copyWith(color: AdminColors.gold)),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: AdminConstants.spacingXs),
                  Text(body, style: AdminTextStyles.body.copyWith(height: 1.6)),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
