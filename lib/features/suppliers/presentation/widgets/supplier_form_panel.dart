import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_image_picker.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../domain/entities/supplier.dart';
import '../cubits/suppliers_cubit.dart';

class SupplierFormPanel extends StatefulWidget {
  final Supplier? supplier;
  final SuppliersCubit cubit;

  const SupplierFormPanel({super.key, this.supplier, required this.cubit});

  @override
  State<SupplierFormPanel> createState() => _SupplierFormPanelState();
}

class _SupplierFormPanelState extends State<SupplierFormPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  List<Uint8List> _logo = [];

  bool get _isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _nameController = TextEditingController(text: s?.name ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _logo = s?.logoBytes != null ? [s!.logoBytes!] : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final supplier = Supplier(
      id: widget.supplier?.id ?? 'SUP-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      logoBytes: _logo.isEmpty ? null : _logo.first,
      description: _descriptionController.text.trim(),
    );
    _isEditing ? widget.cubit.updateSupplier(supplier) : widget.cubit.addSupplier(supplier);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminField(
          label: AdminStrings.supplierName,
          isRequired: true,
          child: AdminTextInput(controller: _nameController),
        ),
        AdminField(
          label: AdminStrings.supplierDescription,
          child: AdminTextInput(controller: _descriptionController, maxLines: 3),
        ),
        AdminField(
          label: AdminStrings.supplierLogo,
          // One logo, one image — picking a new one replaces the old.
          child: AdminImagePicker(
            images: _logo,
            onChanged: (imgs) => setState(() => _logo = imgs.isEmpty ? [] : [imgs.last]),
          ),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminButton(label: AdminStrings.save, onPressed: _save),
      ],
    );
  }
}