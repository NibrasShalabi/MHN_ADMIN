import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../theme/admin_colors.dart';

enum AdminButtonKind { primary, secondary, danger }

class AdminButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AdminButtonKind kind;

  const AdminButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.kind = AdminButtonKind.primary,
  });

  @override
  Widget build(BuildContext context) {
    final background = switch (kind) {
      AdminButtonKind.primary => AdminColors.primary,
      AdminButtonKind.secondary => Colors.transparent,
      AdminButtonKind.danger => AdminColors.danger,
    };

    final foreground = kind == AdminButtonKind.secondary
        ? AdminColors.gold
        : AdminColors.textPrimary;

    return SizedBox(
      height: AdminConstants.fieldHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
            side: BorderSide(
              color: kind == AdminButtonKind.secondary
                  ? AdminColors.border
                  : Colors.transparent,
              width: AdminConstants.borderThin,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AdminConstants.spacingLg),
        ),
      ),
    );
  }
}

/// Inline text action — used for "select all" style shortcuts where a
/// full button would dominate the row it sits under.
class AdminTextAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AdminTextAction({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXs),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            color: AdminColors.gold,
          ),
        ),
      ),
    );
  }
}