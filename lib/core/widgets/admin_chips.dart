import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../constants/admin_strings.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';
import 'admin_button.dart';

/// A single selectable pill. Used on its own for one-of choices and by
/// [AdminChoiceChips] for many-of.
class AdminChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? leading;

  const AdminChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AdminConstants.spacingMd,
          vertical: AdminConstants.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primary : AdminColors.canvas,
          borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
          border: Border.all(
            color: isSelected ? AdminColors.gold : AdminColors.border,
            width: AdminConstants.borderThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AdminConstants.spacingSm),
            ],
            Text(
              label,
              style: AdminTextStyles.body.copyWith(
                color: isSelected ? AdminColors.textPrimary : AdminColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multi-select chip group — the workhorse of "choose, don't type".
class AdminChoiceChips<T> extends StatelessWidget {
  final List<T> options;
  final Set<T> selected;
  final String Function(T) labelOf;
  final ValueChanged<Set<T>> onChanged;

  /// Worth showing when a set has ten sizes and the product carries most
  /// of them; noise when there are three options.
  final bool allowSelectAll;

  const AdminChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.allowSelectAll = true,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Text(AdminStrings.noData, style: AdminTextStyles.caption);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AdminConstants.spacingSm,
          runSpacing: AdminConstants.spacingSm,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return AdminChip(
              label: labelOf(option),
              isSelected: isSelected,
              onTap: () {
                final next = {...selected};
                isSelected ? next.remove(option) : next.add(option);
                onChanged(next);
              },
            );
          }).toList(),
        ),
        if (allowSelectAll) ...[
          const SizedBox(height: AdminConstants.spacingSm),
          Row(
            children: [
              AdminTextAction(
                label: AdminStrings.selectAll,
                onTap: () => onChanged(options.toSet()),
              ),
              const SizedBox(width: AdminConstants.spacingMd),
              AdminTextAction(
                label: AdminStrings.clearAll,
                onTap: () => onChanged({}),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Single-select chip group, with an explicit "none" option.
class AdminOptionChips<T> extends StatelessWidget {
  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final bool allowNone;

  const AdminOptionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.allowNone = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AdminConstants.spacingSm,
      runSpacing: AdminConstants.spacingSm,
      children: [
        if (allowNone)
          AdminChip(
            label: AdminStrings.none,
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
        ...options.map(
              (option) => AdminChip(
            label: labelOf(option),
            isSelected: option == selected,
            onTap: () => onChanged(option),
          ),
        ),
      ],
    );
  }
}