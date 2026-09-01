import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../presets/domain/entities/presets.dart';

/// The variants block of the product form.
///
/// This is where "choose, don't type" earns its keep. The admin picks a
/// size set, ticks which of its sizes this item carries, ticks colours off
/// the shared palette, and attaches a saved size chart. Nothing is typed,
/// so nothing drifts: "L" is always "L", and "أسود" is always the same
/// hex across the whole catalogue.
class ProductVariantsSection extends StatelessWidget {
  final CatalogPresets presets;

  final SizeSet? sizeSet;
  final Set<String> selectedSizes;
  final Set<String> selectedColorIds;
  final SizeGuideTemplate? sizeGuide;

  final ValueChanged<SizeSet?> onSizeSetChanged;
  final ValueChanged<Set<String>> onSizesChanged;
  final ValueChanged<Set<String>> onColorsChanged;
  final ValueChanged<SizeGuideTemplate?> onSizeGuideChanged;

  const ProductVariantsSection({
    super.key,
    required this.presets,
    required this.sizeSet,
    required this.selectedSizes,
    required this.selectedColorIds,
    required this.sizeGuide,
    required this.onSizeSetChanged,
    required this.onSizesChanged,
    required this.onColorsChanged,
    required this.onSizeGuideChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: AdminStrings.variants,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminField(
            label: AdminStrings.sizeSet,
            hint: AdminStrings.sizeSetHint,
            child: AdminOptionChips<SizeSet>(
              options: presets.sizeSets,
              selected: sizeSet,
              labelOf: (set) => set.name,
              onChanged: (set) {
                onSizeSetChanged(set);
                // Switching sets clears the ticks: keeping "M" selected
                // after moving to shoe sizes would silently save a size
                // the set doesn't contain.
                onSizesChanged(set == null ? {} : set.sizes.toSet());
              },
            ),
          ),

          if (sizeSet != null)
            AdminField(
              label: AdminStrings.availableSizes,
              hint: AdminStrings.availableSizesHint,
              child: AdminChoiceChips<String>(
                options: sizeSet!.sizes,
                selected: selectedSizes,
                labelOf: (size) => size,
                onChanged: onSizesChanged,
              ),
            ),

          AdminField(
            label: AdminStrings.availableColors,
            hint: AdminStrings.availableColorsHint,
            child: _ColorPicker(
              colors: presets.colors,
              selectedIds: selectedColorIds,
              onChanged: onColorsChanged,
            ),
          ),

          AdminField(
            label: AdminStrings.sizeGuide,
            hint: AdminStrings.sizeGuideHint,
            child: _SizeGuidePicker(
              templates: presets.sizeGuides,
              selected: sizeGuide,
              onChanged: onSizeGuideChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeGuidePicker extends StatelessWidget {
  final List<SizeGuideTemplate> templates;
  final SizeGuideTemplate? selected;
  final ValueChanged<SizeGuideTemplate?> onChanged;

  const _SizeGuidePicker({
    required this.templates,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminOptionChips<SizeGuideTemplate>(
          options: templates,
          selected: selected,
          labelOf: (template) => template.name,
          onChanged: onChanged,
        ),
        if (selected != null) ...[
          const SizedBox(height: AdminConstants.spacingMd),
          // Preview the chart inline — picking a template by name alone
          // means finding out it was the wrong one from the storefront.
          _SizeGuidePreview(template: selected!),
        ],
      ],
    );
  }
}

class _SizeGuidePreview extends StatelessWidget {
  final SizeGuideTemplate template;

  const _SizeGuidePreview({required this.template});

  @override
  Widget build(BuildContext context) {
    final columns =
    template.rows.isEmpty ? <String>[] : template.rows.first.measurements.keys.toList();

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.canvas,
        borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
        border: Border.all(color: AdminColors.border, width: AdminConstants.borderThin),
      ),
      padding: const EdgeInsets.all(AdminConstants.spacingMd),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              _cell(AdminStrings.sizeColumn, isHeader: true),
              ...columns.map((c) => _cell(c, isHeader: true)),
            ],
          ),
          ...template.rows.map(
                (row) => TableRow(
              children: [
                _cell(row.size),
                ...columns.map((c) => _cell(row.measurements[c] ?? '—')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXs),
      child: Text(
        text,
        style: isHeader ? AdminTextStyles.tableHeader : AdminTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final List<PaletteColor> colors;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  const _ColorPicker({
    required this.colors,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AdminConstants.spacingSm,
      runSpacing: AdminConstants.spacingSm,
      children: colors.map((color) {
        final isSelected = selectedIds.contains(color.id);

        return AdminChip(
          label: color.name,
          isSelected: isSelected,
          // The swatch is the point: a colour picked by name alone is how
          // three different beiges end up in one catalogue.
          leading: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Color(color.value),
              shape: BoxShape.circle,
              border: Border.all(
                color: AdminColors.border,
                width: AdminConstants.borderThin,
              ),
            ),
          ),
          onTap: () {
            final next = {...selectedIds};
            isSelected ? next.remove(color.id) : next.add(color.id);
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}