import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

/// Slide-in panel for short forms — a category, a filter, a preset.
///
/// Keeps the list visible behind it, which is what makes several quick
/// edits in a row fast. Long forms — a product with images and variants —
/// get their own page; this width would strangle them.
Future<T?> showAdminSidePanel<T>(
    BuildContext context, {
      required String title,
      required Widget child,
    }) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) => _Panel(
      title: title,
      child: child,
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Enters from the start edge, which in RTL is the right — the same
      // side the panel is anchored to.
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
  );
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;

  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Material(
        color: AdminColors.surface,
        child: SizedBox(
          width: AdminConstants.sidePanelWidth,
          height: double.infinity,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AdminConstants.spacingLg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title, style: AdminTextStyles.sectionTitle),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AdminColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AdminColors.border, height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AdminConstants.spacingLg),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}