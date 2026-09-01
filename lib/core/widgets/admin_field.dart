import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

/// Label + optional hint above any input, so the required marker and the
/// spacing between fields are decided once.
class AdminField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? hint;
  final Widget child;

  const AdminField({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AdminTextStyles.label),
              if (isRequired)
                const Text(' *', style: TextStyle(color: AdminColors.danger)),
            ],
          ),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(hint!, style: AdminTextStyles.caption),
          ],
          const SizedBox(height: AdminConstants.spacingSm),
          child,
        ],
      ),
    );
  }
}