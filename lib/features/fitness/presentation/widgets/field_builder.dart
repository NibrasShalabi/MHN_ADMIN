import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../domain/entities/dynamic_form_field.dart';
import 'form_field_type_x.dart';

class FieldBuilder extends StatelessWidget {
  final List<DynamicFormField> fields;
  final ValueChanged<List<DynamicFormField>> onChanged;

  const FieldBuilder({super.key, required this.fields, required this.onChanged});

  void _updateAt(int index, DynamicFormField field) {
    final next = [...fields];
    next[index] = field;
    onChanged(next);
  }

  void _removeAt(int index) {
    final next = [...fields]..removeAt(index);
    onChanged(next);
  }

  void _addField() {
    onChanged([
      ...fields,
      DynamicFormField(id: 'field_${DateTime.now().millisecondsSinceEpoch}', label: '', type: FormFieldType.text),
    ]);
  }

  void _addBasicHealthFields() {
    final t = DateTime.now().millisecondsSinceEpoch;
    onChanged([
      ...fields,
      DynamicFormField(id: 'age_$t', label: 'العمر', type: FormFieldType.number, isRequired: true),
      DynamicFormField(id: 'height_$t', label: 'الطول', type: FormFieldType.number, isRequired: true),
      DynamicFormField(id: 'weight_$t', label: 'الوزن', type: FormFieldType.number, isRequired: true),
      DynamicFormField(id: 'chronic_$t', label: 'أمراض مزمنة', type: FormFieldType.multiline),
      DynamicFormField(id: 'hereditary_$t', label: 'أمراض وراثية', type: FormFieldType.multiline),
    ]);
  }

  void _reorder(int oldIndex, int newIndex) {
    final next = [...fields];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminButton(
          label: AdminStrings.basicHealthFields,
          kind: AdminButtonKind.secondary,
          icon: Icons.health_and_safety_outlined,
          onPressed: _addBasicHealthFields,
        ),
        const SizedBox(height: AdminConstants.spacingSm),
        if (fields.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingMd),
            child: Text(AdminStrings.noData, style: AdminTextStyles.caption),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: fields.length,
            onReorder: _reorder,
            itemBuilder: (context, index) => _FieldRow(
              key: ValueKey(fields[index].id),
              index: index,
              field: fields[index],
              onChanged: (f) => _updateAt(index, f),
              onRemove: () => _removeAt(index),
            ),
          ),
        const SizedBox(height: AdminConstants.spacingSm),
        AdminButton(
          label: AdminStrings.addField,
          icon: Icons.add,
          kind: AdminButtonKind.secondary,
          onPressed: _addField,
        ),
      ],
    );
  }
}

class _FieldRow extends StatefulWidget {
  final int index;
  final DynamicFormField field;
  final ValueChanged<DynamicFormField> onChanged;
  final VoidCallback onRemove;

  const _FieldRow({
    super.key,
    required this.index,
    required this.field,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_FieldRow> createState() => _FieldRowState();
}

class _FieldRowState extends State<_FieldRow> {
  late final TextEditingController _labelController;
  late final TextEditingController _optionsController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.field.label);
    _optionsController = TextEditingController(text: widget.field.options.join('، '));
  }

  @override
  void dispose() {
    _labelController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;

    return Container(
      margin: const EdgeInsets.only(bottom: AdminConstants.spacingMd),
      padding: const EdgeInsets.all(AdminConstants.spacingMd),
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
              ReorderableDragStartListener(
                index: widget.index,
                child: const Padding(
                  padding: EdgeInsets.only(left: AdminConstants.spacingSm),
                  child: Icon(Icons.drag_handle, color: AdminColors.textSecondary, size: 20),
                ),
              ),
              Expanded(
                child: AdminTextInput(
                  controller: _labelController,
                  hint: AdminStrings.fieldLabel,
                  onChanged: (v) => widget.onChanged(field.copyWith(label: v)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AdminColors.danger),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          const SizedBox(height: AdminConstants.spacingSm),
          Text(AdminStrings.fieldType, style: AdminTextStyles.caption),
          const SizedBox(height: AdminConstants.spacingXs),
          AdminOptionChips<FormFieldType>(
            options: FormFieldType.values,
            selected: field.type,
            allowNone: false,
            labelOf: (t) => t.label,
            onChanged: (t) => widget.onChanged(field.copyWith(type: t)),
          ),
          if (field.type.needsOptions) ...[
            const SizedBox(height: AdminConstants.spacingSm),
            AdminTextInput(
              controller: _optionsController,
              hint: AdminStrings.fieldOptions,
              onChanged: (v) => widget.onChanged(field.copyWith(
                options: v.split(RegExp('[،,]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
              )),
            ),
          ],
          const SizedBox(height: AdminConstants.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AdminStrings.fieldRequired, style: AdminTextStyles.caption),
              Switch(
                value: field.isRequired,
                activeColor: AdminColors.gold,
                onChanged: (v) => widget.onChanged(field.copyWith(isRequired: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}