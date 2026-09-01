import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

class AdminTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const AdminTextInput({
    super.key,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.errorText,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      onChanged: onChanged,
      style: AdminTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AdminTextStyles.caption,
        errorText: errorText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AdminConstants.spacingMd,
          vertical: AdminConstants.spacingSm + 2,
        ),
        filled: true,
        fillColor: AdminColors.canvas,
        border: _border(AdminColors.border),
        enabledBorder: _border(AdminColors.border),
        focusedBorder: _border(AdminColors.gold),
        errorBorder: _border(AdminColors.danger),
        focusedErrorBorder: _border(AdminColors.danger),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
    borderSide: BorderSide(color: color, width: AdminConstants.borderThin),
  );
}