import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../cubits/loyalty_ledger_cubit.dart';

class CorrectionFormPanel extends StatefulWidget {
  final LoyaltyLedgerCubit cubit;

  const CorrectionFormPanel({super.key, required this.cubit});

  @override
  State<CorrectionFormPanel> createState() => _CorrectionFormPanelState();
}

class _CorrectionFormPanelState extends State<CorrectionFormPanel> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pointsController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pointsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _save() {
    final points = int.tryParse(_pointsController.text.trim());
    if (points == null || _nameController.text.trim().isEmpty || _reasonController.text.trim().isEmpty) return;

    widget.cubit.addCorrection(
      userName: _nameController.text.trim(),
      userPhone: _phoneController.text.trim(),
      points: points,
      reason: _reasonController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminField(
          label: AdminStrings.customer,
          isRequired: true,
          child: AdminTextInput(controller: _nameController),
        ),
        AdminField(
          label: AdminStrings.customerPhone,
          child: AdminTextInput(controller: _phoneController),
        ),
        AdminField(
          label: AdminStrings.correctionPoints,
          isRequired: true,
          child: AdminTextInput(controller: _pointsController, keyboardType: TextInputType.number),
        ),
        AdminField(
          label: AdminStrings.correctionReason,
          isRequired: true,
          child: AdminTextInput(controller: _reasonController, maxLines: 2),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminButton(label: AdminStrings.save, onPressed: _save),
      ],
    );
  }
}