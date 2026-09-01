import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../theme/admin_text_styles.dart';

/// Status pill for table rows — tinted fill with a matching border, so it
/// stays legible at caption size against the row background.
class AdminStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const AdminStatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminConstants.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
        border: Border.all(color: color, width: AdminConstants.borderThin),
      ),
      child: Text(label, style: AdminTextStyles.caption.copyWith(color: color)),
    );
  }
}