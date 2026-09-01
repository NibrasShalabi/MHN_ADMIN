import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../domain/entities/dynamic_form_field.dart';

class FormPreview extends StatelessWidget {
  final String title;
  final String intro;
  final List<DynamicFormField> fields;

  const FormPreview({super.key, required this.title, required this.intro, required this.fields});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: AdminStrings.livePreview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) Text(title, style: AdminTextStyles.sectionTitle),
          if (intro.isNotEmpty) ...[
            const SizedBox(height: AdminConstants.spacingSm),
            Text(intro, style: AdminTextStyles.caption),
          ],
          const SizedBox(height: AdminConstants.spacingLg),
          if (fields.isEmpty)
            Text(AdminStrings.noData, style: AdminTextStyles.caption)
          else
            ...fields.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: AdminConstants.spacingMd),
              child: _PreviewField(field: f),
            )),
        ],
      ),
    );
  }
}

class _PreviewField extends StatelessWidget {
  final DynamicFormField field;

  const _PreviewField({required this.field});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(field.label.isEmpty ? '—' : field.label, style: AdminTextStyles.label),
            if (field.isRequired) const Text(' *', style: TextStyle(color: AdminColors.danger)),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingXs),
        _buildInput(),
      ],
    );
  }

  Widget _buildInput() {
    switch (field.type) {
      case FormFieldType.boolean:
        return const Switch(value: false, onChanged: null, activeColor: AdminColors.gold);
      case FormFieldType.dropdown:
        return _box(field.options.isEmpty ? AdminStrings.none : field.options.first);
      case FormFieldType.multiChoice:
        return Wrap(
          spacing: AdminConstants.spacingSm,
          children: field.options
              .map((o) => Chip(label: Text(o, style: AdminTextStyles.caption), backgroundColor: AdminColors.surfaceRaised))
              .toList(),
        );
      case FormFieldType.multiline:
        return _box('', height: 60);
      case FormFieldType.number:
      case FormFieldType.text:
        return _box('');
    }
  }

  Widget _box(String text, {double height = 40}) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: AdminConstants.spacingMd),
      alignment: AlignmentDirectional.centerStart,
      decoration: BoxDecoration(
        color: AdminColors.canvas,
        borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
        border: Border.all(color: AdminColors.border, width: AdminConstants.borderThin),
      ),
      child: Text(text, style: AdminTextStyles.caption),
    );
  }
}