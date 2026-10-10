import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../constants/admin_strings.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

/// Yes/no before anything the customer will see. Resolves to false when
/// dismissed.
Future<bool> showAdminConfirm(BuildContext context, {required String title, String? message, Widget? content}) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.surface,
        title: Text(title, style: AdminTextStyles.sectionTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null) Text(message, style: AdminTextStyles.caption),
            if (content != null) ...[const SizedBox(height: AdminConstants.spacingMd), content],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AdminStrings.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AdminStrings.confirm)),
        ],
      ),
    ) ??
    false;
