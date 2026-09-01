import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../domain/entities/presets.dart';
import '../cubits/presets_cubit.dart';

class SizeSetFormPanel extends StatefulWidget {
  final SizeSet? sizeSet;
  final PresetsCubit cubit;

  const SizeSetFormPanel({super.key, this.sizeSet, required this.cubit});

  @override
  State<SizeSetFormPanel> createState() => _SizeSetFormPanelState();
}

class _SizeSetFormPanelState extends State<SizeSetFormPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _sizesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sizeSet?.name ?? '');
    _sizesController = TextEditingController(text: widget.sizeSet?.sizes.join('، ') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizesController.dispose();
    super.dispose();
  }

  void _save() {
    final sizes = _sizesController.text
        .split(RegExp('[،,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final set = SizeSet(
      id: widget.sizeSet?.id ?? 'SS-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      sizes: sizes,
    );

    widget.sizeSet == null ? widget.cubit.addSizeSet(set) : widget.cubit.updateSizeSet(set);
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
        AdminField(
          label: AdminStrings.sizesCommaSeparated,
          isRequired: true,
          child: AdminTextInput(controller: _sizesController),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminButton(label: AdminStrings.save, onPressed: _save),
      ],
    );
  }
}