import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';

/// Lays [children] out as a row on wide screens and a stacked column on
/// narrow ones, with consistent spacing either way. Extracted from
/// analytics_page.dart, where this exact LayoutBuilder was written three
/// times with only the spacing constant and the widget list changing —
/// any page arranging a handful of cards/tables side by side reuses this
/// instead of another copy.
class AdminResponsiveRow extends StatelessWidget {
  final List<Widget> children;

  /// Below this width, [children] stack vertically instead of sitting
  /// in a row.
  final double breakpoint;

  const AdminResponsiveRow({
    super.key,
    required this.children,
    this.breakpoint = 900,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= breakpoint) {
          return Column(
            children: [
              for (final child in children) ...[
                child,
                if (child != children.last)
                  const SizedBox(height: AdminConstants.spacingLg),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final child in children) ...[
              Expanded(child: child),
              if (child != children.last)
                const SizedBox(width: AdminConstants.spacingLg),
            ],
          ],
        );
      },
    );
  }
}