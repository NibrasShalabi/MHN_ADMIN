import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_image_picker.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../domain/entities/supplier.dart';
import '../cubits/suppliers_cubit.dart';

/// The shop's identity and how customers reach it. Used in the "add"
/// side panel and on the supplier's own page.
class SupplierFormPanel extends StatefulWidget {
  final Supplier? supplier;
  final SuppliersCubit cubit;

  /// Runs after a successful save (the side panel closes itself here).
  final VoidCallback? onSaved;

  const SupplierFormPanel({super.key, this.supplier, required this.cubit, this.onSaved});

  @override
  State<SupplierFormPanel> createState() => _SupplierFormPanelState();
}

class _SupplierFormPanelState extends State<SupplierFormPanel> {
  static final _phonePattern = RegExp(r'^[0-9]{9,15}$');

  late final _name = TextEditingController(text: widget.supplier?.name ?? '');
  late final _description = TextEditingController(text: widget.supplier?.description ?? '');
  late final _phone = TextEditingController(text: widget.supplier?.phone ?? '');
  late final _address = TextEditingController(text: widget.supplier?.address ?? '');
  late final _maps = TextEditingController(text: widget.supplier?.mapsUrl ?? '');
  late bool _active = widget.supplier?.isActive ?? true;
  late List<Uint8List> _logo = [?widget.supplier?.logoBytes];
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _description, _phone, _address, _maps]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _phoneDigits => _phone.text.replaceAll(RegExp(r'[^0-9]'), '');
  bool get _phoneOk => _phonePattern.hasMatch(_phoneDigits);
  bool get _mapsOk => _maps.text.trim().isEmpty || Uri.tryParse(_maps.text.trim())?.hasScheme == true;
  bool get _valid => _name.text.trim().isNotEmpty && _phoneOk && _mapsOk;

  Future<void> _save() async {
    setState(() => _saving = true);
    final supplier = Supplier(
      id: widget.supplier?.id ?? 'SUP-${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      logoBytes: _logo.firstOrNull,
      description: _description.text.trim(),
      phone: _phoneDigits,
      address: _address.text.trim(),
      mapsUrl: _maps.text.trim(),
      isActive: _active,
      ownerUid: widget.supplier?.ownerUid,
    );
    final ok = widget.supplier == null
        ? await widget.cubit.addSupplier(supplier)
        : await widget.cubit.updateSupplier(supplier);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? AdminStrings.saved : AdminStrings.somethingWentWrong)),
    );
    if (ok) widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    void refresh(_) => setState(() {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminField(
          label: AdminStrings.supplierName,
          isRequired: true,
          child: AdminTextInput(controller: _name, onChanged: refresh),
        ),
        AdminField(
          label: AdminStrings.supplierPhone,
          isRequired: true,
          hint: AdminStrings.supplierPhoneHint,
          child: AdminTextInput(
            controller: _phone,
            hint: '963912345678',
            keyboardType: TextInputType.phone,
            errorText: _phone.text.isNotEmpty && !_phoneOk ? AdminStrings.specialistWhatsappInvalid : null,
            onChanged: refresh,
          ),
        ),
        AdminField(
          label: AdminStrings.supplierAddress,
          child: AdminTextInput(controller: _address, hint: AdminStrings.supplierAddressHint, onChanged: refresh),
        ),
        AdminField(
          label: AdminStrings.supplierMaps,
          hint: AdminStrings.supplierMapsHint,
          child: AdminTextInput(
            controller: _maps,
            hint: 'https://maps.app.goo.gl/…',
            errorText: _mapsOk ? null : AdminStrings.supplierMapsInvalid,
            onChanged: refresh,
          ),
        ),
        AdminField(
          label: AdminStrings.supplierDescription,
          child: AdminTextInput(controller: _description, maxLines: 3),
        ),
        AdminField(
          label: AdminStrings.supplierLogo,
          // One logo — picking a new one replaces the old.
          child: AdminImagePicker(images: _logo, onChanged: (imgs) => setState(() => _logo = [?imgs.lastOrNull])),
        ),
        Row(
          children: [
            Expanded(child: Text(AdminStrings.supplierActive, style: AdminTextStyles.label)),
            Text(_active ? AdminStrings.sectionLive : AdminStrings.methodOff, style: AdminTextStyles.caption),
            Switch(value: _active, activeThumbColor: AdminColors.gold, onChanged: (v) => setState(() => _active = v)),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminButton(label: AdminStrings.save, onPressed: _saving || !_valid ? null : _save),
      ],
    );
  }
}
