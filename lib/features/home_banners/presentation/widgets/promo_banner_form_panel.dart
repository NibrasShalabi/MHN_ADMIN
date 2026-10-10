import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_dropdown.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_image_picker.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../../categories/data/repository/categories_repository.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../products/data/repository/products_repository.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/promo_banner.dart';
import '../cubits/promo_banners_cubit.dart';

/// A banner: picture, title, order, where a tap goes, and when it shows.
class PromoBannerFormPanel extends StatefulWidget {
  final PromoBanner? banner;
  final PromoBannersCubit cubit;

  const PromoBannerFormPanel({super.key, this.banner, required this.cubit});

  @override
  State<PromoBannerFormPanel> createState() => _PromoBannerFormPanelState();
}

class _PromoBannerFormPanelState extends State<PromoBannerFormPanel> {
  static final DateFormat _date = DateFormat('yyyy/MM/dd', 'ar');

  late final _title = TextEditingController(text: widget.banner?.title ?? '');
  late final _order = TextEditingController(text: '${widget.banner?.order ?? 0}');
  late List<Uint8List> _image = [?widget.banner?.imageBytes];
  late BannerLink _link = widget.banner?.link ?? BannerLink.none;
  late String? _linkId = widget.banner?.linkId;
  late DateTime? _startsAt = widget.banner?.startsAt;
  late DateTime? _endsAt = widget.banner?.endsAt;

  // Store products and store categories — what a home banner promotes.
  final Future<List<Product>> _products = GetIt.instance<ProductsRepository>()
      .getProducts()
      .then((all) => all.where((p) => p.pricing == ProductPricing.money && !p.dealOnly).toList());
  final Future<List<Category>> _categories = GetIt.instance<CategoriesRepository>()
      .getCategories()
      .then((all) => all.where((c) => c.scope == CategoryScope.store).toList());

  @override
  void dispose() {
    _title.dispose();
    _order.dispose();
    super.dispose();
  }

  bool get _valid =>
      (!_link.needsTarget || _linkId != null) &&
      (_startsAt == null || _endsAt == null || _endsAt!.isAfter(_startsAt!));

  Future<void> _pickDate(bool start) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (start ? _startsAt : _endsAt) ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    // The end date counts the whole day.
    setState(() {
      if (start) {
        _startsAt = picked;
      } else {
        _endsAt = picked.add(const Duration(hours: 23, minutes: 59));
      }
    });
  }

  void _save() {
    final banner = PromoBanner(
      id: widget.banner?.id ?? 'B-${DateTime.now().millisecondsSinceEpoch}',
      imageBytes: _image.firstOrNull,
      title: _title.text.trim().isEmpty ? null : _title.text.trim(),
      order: int.tryParse(_order.text.trim()) ?? 0,
      link: _link,
      linkId: _link.needsTarget ? _linkId : null,
      startsAt: _startsAt,
      endsAt: _endsAt,
    );
    if (widget.banner == null) {
      widget.cubit.addBanner(banner);
    } else {
      widget.cubit.updateBanner(banner);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminField(
          label: AdminStrings.bannerImage,
          child: AdminImagePicker(images: _image, onChanged: (imgs) => setState(() => _image = [?imgs.lastOrNull])),
        ),
        AdminField(label: AdminStrings.bannerTitle, child: AdminTextInput(controller: _title)),
        AdminField(
          label: AdminStrings.bannerOrder,
          child: AdminTextInput(controller: _order, keyboardType: TextInputType.number),
        ),
        AdminField(
          label: AdminStrings.bannerLink,
          child: AdminOptionChips<BannerLink>(
            options: BannerLink.values,
            selected: _link,
            allowNone: false,
            labelOf: (l) => switch (l) {
              BannerLink.none => AdminStrings.bannerLinkNone,
              BannerLink.product => AdminStrings.bannerLinkProduct,
              BannerLink.category => AdminStrings.bannerLinkCategory,
              BannerLink.deals => AdminStrings.bannerLinkDeals,
            },
            onChanged: (l) => setState(() {
              if (l != _link) _linkId = null;
              _link = l ?? _link;
            }),
          ),
        ),
        if (_link == BannerLink.product)
          _Target<Product>(future: _products, selectedId: _linkId, idOf: (p) => p.id, labelOf: (p) => p.name,
              onChanged: (id) => setState(() => _linkId = id)),
        if (_link == BannerLink.category)
          _Target<Category>(future: _categories, selectedId: _linkId, idOf: (c) => c.id, labelOf: (c) => c.name,
              onChanged: (id) => setState(() => _linkId = id)),
        AdminField(
          label: AdminStrings.bannerSchedule,
          child: Row(
            children: [
              Expanded(child: _DateButton(label: AdminStrings.bannerStarts, value: _startsAt, format: _date,
                  onTap: () => _pickDate(true), onClear: () => setState(() => _startsAt = null))),
              const SizedBox(width: AdminConstants.spacingSm),
              Expanded(child: _DateButton(label: AdminStrings.bannerEnds, value: _endsAt, format: _date,
                  onTap: () => _pickDate(false), onClear: () => setState(() => _endsAt = null))),
            ],
          ),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminButton(label: AdminStrings.save, onPressed: _valid ? _save : null),
      ],
    );
  }
}

/// Picks the product or category the banner opens.
class _Target<T extends Object> extends StatelessWidget {
  final Future<List<T>> future;
  final String? selectedId;
  final String Function(T) idOf;
  final String Function(T) labelOf;
  final ValueChanged<String?> onChanged;

  const _Target({
    required this.future,
    required this.selectedId,
    required this.idOf,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final items = snap.data!;
        return AdminField(
          label: '',
          child: AdminDropdown<T>(
            value: items.where((i) => idOf(i) == selectedId).firstOrNull,
            items: items,
            labelOf: labelOf,
            hint: AdminStrings.selectProduct,
            onChanged: (i) => onChanged(i == null ? null : idOf(i)),
          ),
        );
      },
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateFormat format;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateButton({required this.label, required this.value, required this.format, required this.onTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
      child: Container(
        height: AdminConstants.fieldHeight,
        padding: const EdgeInsets.symmetric(horizontal: AdminConstants.spacingMd),
        decoration: BoxDecoration(
          color: AdminColors.canvas,
          borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
          border: Border.all(color: AdminColors.border),
        ),
        child: Row(
          children: [
            Text('$label ', style: AdminTextStyles.caption),
            Expanded(
              child: Text(value == null ? AdminStrings.bannerAlways : format.format(value!), style: AdminTextStyles.body),
            ),
            if (value != null)
              InkWell(onTap: onClear, child: const Icon(Icons.close, size: 16, color: AdminColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
