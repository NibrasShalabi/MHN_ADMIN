import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../theme/admin_text_styles.dart';

/// Color dot + label, for a chart legend. Extracted from
/// analytics_page.dart — any future chart on this page (or elsewhere)
/// needing a legend entry reuses this.
class AdminLegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const AdminLegendDot({
    super.key,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AdminConstants.spacingXs),
        Text('$label ($value)', style: AdminTextStyles.caption),
      ],
    );
  }
}