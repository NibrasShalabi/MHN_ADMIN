import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../domain/entities/presets.dart';
import '../cubits/presets_cubit.dart';

class SizeGuideFormPanel extends StatefulWidget {
  final SizeGuideTemplate? guide;
  final PresetsCubit cubit;

  const SizeGuideFormPanel({super.key, this.guide, required this.cubit});

  @override
  State<SizeGuideFormPanel> createState() => _SizeGuideFormPanelState();
}

class _SizeGuideFormPanelState extends State<SizeGuideFormPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _newColumnController;
  late List<String> _columns;
  late List<Map<String, String>> _rows; // each row has 'size' + measurement keys

  @override
  void initState() {
    super.initState();
    final g = widget.guide;
    _nameController = TextEditingController(text: g?.name ?? '');
    _newColumnController = TextEditingController();
    _columns = g == null ? [] : g.rows.expand((r) => r.measurements.keys).toSet().toList();
    _rows = g == null
        ? []
        : g.rows.map((r) => {'size': r.size, ...r.measurements}).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newColumnController.dispose();
    super.dispose();
  }

  void _addColumn() {
    final name = _newColumnController.text.trim();
    if (name.isEmpty || _columns.contains(name)) return;
    setState(() {
      _columns.add(name);
      _newColumnController.clear();
    });
  }

  void _removeColumn(String name) {
    setState(() {
      _columns.remove(name);
      for (final row in _rows) {
        row.remove(name);
      }
    });
  }

  void _addRow() {
    setState(() => _rows.add({'size': ''}));
  }

  void _removeRow(int index) {
    setState(() => _rows.removeAt(index));
  }

  void _save() {
    final rows = _rows
        .where((r) => (r['size'] ?? '').trim().isNotEmpty)
        .map((r) {
      final measurements = {...r}..remove('size');
      return SizeGuideTemplateRow(size: r['size']!.trim(), measurements: measurements);
    })
        .toList();

    final guide = SizeGuideTemplate(
      id: widget.guide?.id ?? 'SG-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      rows: rows,
    );

    widget.guide == null ? widget.cubit.addSizeGuide(guide) : widget.cubit.updateSizeGuide(guide);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminField(
          label: AdminStrings.presetName,
          isRequired: true,
          child: AdminTextInput(controller: _nameController),
        ),
        Text(AdminStrings.filters, style: AdminTextStyles.tableHeader), // "الأعمدة" placeholder unavailable
        const SizedBox(height: AdminConstants.spacingSm),
        Wrap(
          spacing: AdminConstants.spacingSm,
          runSpacing: AdminConstants.spacingSm,
          children: _columns
              .map((c) => Chip(
            label: Text(c, style: AdminTextStyles.caption),
            onDeleted: () => _removeColumn(c),
            backgroundColor: AdminColors.canvas,
            deleteIconColor: AdminColors.danger,
          ))
              .toList(),
        ),
        const SizedBox(height: AdminConstants.spacingSm),
        Row(
          children: [
            Expanded(
              child: AdminTextInput(controller: _newColumnController, hint: AdminStrings.columnName),
            ),
            const SizedBox(width: AdminConstants.spacingSm),
            AdminButton(label: AdminStrings.addColumn, kind: AdminButtonKind.secondary, onPressed: _addColumn),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        Text(AdminStrings.rows, style: AdminTextStyles.tableHeader),
        const SizedBox(height: AdminConstants.spacingSm),
        ..._rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AdminConstants.spacingSm),
            padding: const EdgeInsets.all(AdminConstants.spacingSm),
            decoration: BoxDecoration(
              color: AdminColors.canvas,
              borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
              border: Border.all(color: AdminColors.border, width: AdminConstants.borderThin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: row['size'],
                        style: AdminTextStyles.body,
                        decoration: const InputDecoration(hintText: AdminStrings.sizeColumn, isDense: true),
                        onChanged: (v) => row['size'] = v,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AdminColors.danger),
                      onPressed: () => _removeRow(index),
                    ),
                  ],
                ),
                ..._columns.map(
                      (col) => Padding(
                    padding: const EdgeInsets.only(top: AdminConstants.spacingXs),
                    child: TextFormField(
                      initialValue: row[col],
                      style: AdminTextStyles.body,
                      decoration: InputDecoration(hintText: col, isDense: true),
                      onChanged: (v) => row[col] = v,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        AdminButton(label: AdminStrings.addRow, kind: AdminButtonKind.secondary, onPressed: _addRow),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminButton(label: AdminStrings.save, onPressed: _save),
      ],
    );
  }
} 