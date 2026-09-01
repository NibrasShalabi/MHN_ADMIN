import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../domain/entities/presets.dart';
import '../cubits/presets_cubit.dart';

class ColorFormPanel extends StatefulWidget {
  final PaletteColor? color;
  final PresetsCubit cubit;

  const ColorFormPanel({super.key, this.color, required this.cubit});

  @override
  State<ColorFormPanel> createState() => _ColorFormPanelState();
}

class _ColorFormPanelState extends State<ColorFormPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.color?.name ?? '');
    _hexController = TextEditingController(
      text: widget.color == null
          ? ''
          : widget.color!.value.toRadixString(16).substring(2).toUpperCase(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  int? get _parsedValue {
    final hex = _hexController.text.trim().replaceAll('#', '');
    if (hex.length != 6) return null;
    final parsed = int.tryParse(hex, radix: 16);
    return parsed == null ? null : (0xFF000000 | parsed);
  }

  void _save() {
    final value = _parsedValue;
    if (value == null) return;

    final color = PaletteColor(
      id: widget.color?.id ?? 'PC-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      value: value,
    );

    widget.color == null ? widget.cubit.addColor(color) : widget.cubit.updateColor(color);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        final preview = _parsedValue;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminField(
              label: AdminStrings.colorName,
              isRequired: true,
              child: AdminTextInput(controller: _nameController),
            ),
            AdminField(
              label: AdminStrings.colorHex,
              isRequired: true,
              hint: 'مثال: DE9A34',
              child: AdminTextInput(
                controller: _hexController,
                onChanged: (_) => setLocalState(() {}),
              ),
            ),
            if (preview != null) ...[
              const SizedBox(height: AdminConstants.spacingSm),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(preview),
                      shape: BoxShape.circle,
                      border: Border.all(color: AdminColors.border),
                    ),
                  ),
                  const SizedBox(width: AdminConstants.spacingSm),
                  const Text(AdminStrings.colorPreview),
                ],
              ),
            ],
            const SizedBox(height: AdminConstants.spacingLg),
            AdminButton(label: AdminStrings.save, onPressed: preview == null ? null : _save),
          ],
        );
      },
    );
  }
}