import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

/// The one dropdown style for the dashboard.
///
/// Keyed on [value] so a parent resetting the selection (e.g. clearing the
/// filter when the category changes) is reflected — `initialValue` alone
/// only applies on first build.
class AdminDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T item) labelOf;
  final String hint;
  final ValueChanged<T?> onChanged;

  const AdminDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
      borderSide: const BorderSide(color: AdminColors.border),
    );

    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: items.contains(value) ? value : null,
      dropdownColor: AdminColors.surfaceRaised,
      style: AdminTextStyles.body,
      decoration: InputDecoration(
        filled: true,
        fillColor: AdminColors.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AdminConstants.spacingMd,
          vertical: AdminConstants.spacingSm,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: AdminColors.gold)),
      ),
      hint: Text(hint, style: AdminTextStyles.caption),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(labelOf(item), style: AdminTextStyles.body)),
      ],
      onChanged: onChanged,
    );
  }
}
