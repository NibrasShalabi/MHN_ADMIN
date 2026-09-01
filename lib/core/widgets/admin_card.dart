import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

/// The dashboard's standard content block: a bordered panel with an
/// optional titled header.
class AdminCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;

  const AdminCard({
    super.key,
    this.title,
    required this.child,
    this.actions = const [],
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
        border: Border.all(color: AdminColors.border, width: AdminConstants.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminConstants.spacingLg,
                vertical: AdminConstants.spacingMd,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(title!, style: AdminTextStyles.sectionTitle)),
                  ...actions,
                ],
              ),
            ),
            const Divider(color: AdminColors.border, height: 1),
          ],
          Padding(
            padding: padding ?? const EdgeInsets.all(AdminConstants.spacingLg),
            child: child,
          ),
        ],
      ),
    );
  }
}