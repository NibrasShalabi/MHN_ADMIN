import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_image_picker.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../domain/entities/promo_banner.dart';
import '../cubits/promo_banners_cubit.dart';

class PromoBannerFormPanel extends StatefulWidget {
  final PromoBanner? banner;
  final PromoBannersCubit cubit;

  const PromoBannerFormPanel({super.key, this.banner, required this.cubit});

  @override
  State<PromoBannerFormPanel> createState() => _PromoBannerFormPanelState();
}

class _PromoBannerFormPanelState extends State<PromoBannerFormPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _orderController;
  List<Uint8List> _image = [];

  bool get _isEditing => widget.banner != null;

  @override
  void initState() {
    super.initState();
    final b = widget.banner;
    _titleController = TextEditingController(text: b?.title ?? '');
    _orderController = TextEditingController(text: '${b?.order ?? 0}');
    _image = b?.imageBytes != null ? [b!.imageBytes!] : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _save() {
    final banner = PromoBanner(
      id: widget.banner?.id ?? 'B-${DateTime.now().millisecondsSinceEpoch}',
      imageBytes: _image.isEmpty ? null : _image.first,
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      order: int.tryParse(_orderController.text.trim()) ?? 0,
    );
    _isEditing ? widget.cubit.updateBanner(banner) : widget.cubit.addBanner(banner);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminField(
          label: AdminStrings.bannerImage,
          isRequired: true,
          child: AdminImagePicker(
            images: _image,
            onChanged: (imgs) => setState(() => _image = imgs.isEmpty ? [] : [imgs.last]),
          ),
        ),
        AdminField(
          label: AdminStrings.bannerTitle,
          child: AdminTextInput(controller: _titleController),
        ),
        AdminField(
          label: AdminStrings.bannerOrder,
          child: AdminTextInput(controller: _orderController, keyboardType: TextInputType.number),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminButton(label: AdminStrings.save, onPressed: _save),
      ],
    );
  }
}
