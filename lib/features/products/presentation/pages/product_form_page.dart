import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mhn_admin/features/products/presentation/pages/products_page.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_image_picker.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../../presets/domain/entities/presets.dart';
import '../../../presets/presentation/widgets/product_variants_section.dart';
import '../../domain/entities/product.dart';
import '../cubits/products_cubit.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  final ProductsPricingMode pricingMode;

  const ProductFormPage({
    super.key,
    this.product,
    this.pricingMode = ProductsPricingMode.currency,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  static const CatalogPresets _presets = DefaultPresets.all;

  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _ingredientsController;
  late final TextEditingController _benefitsController;
  late final TextEditingController _usageController;

  late List<Uint8List> _images;
  late bool _isNew;
  late bool _isOrderable;
  SizeSet? _sizeSet;
  late Set<String> _sizes;
  late Set<String> _colorIds;
  SizeGuideTemplate? _sizeGuide;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _priceController = TextEditingController(
      text: p == null ? '' : p.price.toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: p == null ? '' : p.stock.toString(),
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _ingredientsController = TextEditingController(text: p?.ingredients ?? '');
    _benefitsController = TextEditingController(text: p?.benefits ?? '');
    _usageController = TextEditingController(text: p?.usage ?? '');
    _images = [...?p?.images];
    _isNew = p?.isNew ?? false;
    _isOrderable = p?.isOrderable ?? true;
    _sizeSet = p?.sizeSet;
    _sizes = {...?p?.sizes};
    _colorIds = {...?p?.colorIds};
    _sizeGuide = p?.sizeGuide;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _benefitsController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  void _save() {
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    final product = Product(
      id: widget.product?.id ?? 'P-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      price: price,
      stock: stock,
      description: _descriptionController.text.trim(),
      ingredients: _ingredientsController.text.trim().isEmpty
          ? null
          : _ingredientsController.text.trim(),
      benefits: _benefitsController.text.trim().isEmpty
          ? null
          : _benefitsController.text.trim(),
      usage: _usageController.text.trim().isEmpty
          ? null
          : _usageController.text.trim(),
      images: _images,
      isNew: _isNew,
      isOrderable: _isOrderable,
      sizeSet: _sizeSet,
      sizes: _sizes,
      colorIds: _colorIds,
      sizeGuide: _sizeGuide,
    );

    final cubit = context.read<ProductsCubit>();
    _isEditing ? cubit.updateProduct(product) : cubit.addProduct(product);
    Navigator.of(context).pop();
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AdminColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AdminConstants.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AdminStrings.deleteConfirm, style: AdminTextStyles.body),
              const SizedBox(height: AdminConstants.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: AdminButton(
                      label: AdminStrings.delete,
                      kind: AdminButtonKind.danger,
                      onPressed: () {
                        context.read<ProductsCubit>().deleteProduct(
                          widget.product!.id,
                        );
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: AdminConstants.spacingSm),
                  Expanded(
                    child: AdminButton(
                      label: AdminStrings.cancel,
                      kind: AdminButtonKind.secondary,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.canvas,
      appBar: AppBar(
        backgroundColor: AdminColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminColors.gold),
        title: Text(
          _isEditing ? AdminStrings.editProduct : AdminStrings.addProduct,
          style: AdminTextStyles.pageTitle,
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AdminColors.danger),
              onPressed: _delete,
            ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AdminConstants.maxContentWidth,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AdminConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminCard(
                  title: AdminStrings.basicInfo,
                  child: Column(
                    children: [
                      AdminField(
                        label: AdminStrings.productName,
                        isRequired: true,
                        child: AdminTextInput(controller: _nameController),
                      ),
                      AdminField(
                        label: AdminStrings.productCategory,
                        child: AdminTextInput(controller: _categoryController),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AdminStrings.productIsNew,
                            style: AdminTextStyles.label,
                          ),
                          Switch(
                            value: _isNew,
                            activeColor: AdminColors.gold,
                            onChanged: (v) => setState(() => _isNew = v),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AdminStrings.productOrderable,
                                  style: AdminTextStyles.label,
                                ),
                                Text(
                                  AdminStrings.productOrderableHint,
                                  style: AdminTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isOrderable,
                            activeColor: AdminColors.gold,
                            onChanged: (v) => setState(() => _isOrderable = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminConstants.spacingLg),
                AdminCard(
                  title: AdminStrings.pricingAndStock,
                  child: Row(
                    children: [
                      Expanded(
                        child: AdminField(
                          label: AdminStrings.productPrice,
                          isRequired: true,
                          child: AdminTextInput(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      const SizedBox(width: AdminConstants.spacingMd),
                      Expanded(
                        child: AdminField(
                          label: AdminStrings.productStock,
                          isRequired: true,
                          child: AdminTextInput(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminConstants.spacingLg),
                AdminCard(
                  title: AdminStrings.productImages,
                  child: AdminImagePicker(
                    images: _images,
                    onChanged: (imgs) => setState(() => _images = imgs),
                  ),
                ),
                const SizedBox(height: AdminConstants.spacingLg),
                ProductVariantsSection(
                  presets: _presets,
                  sizeSet: _sizeSet,
                  selectedSizes: _sizes,
                  selectedColorIds: _colorIds,
                  sizeGuide: _sizeGuide,
                  onSizeSetChanged: (set) => setState(() => _sizeSet = set),
                  onSizesChanged: (sizes) => setState(() => _sizes = sizes),
                  onColorsChanged: (ids) => setState(() => _colorIds = ids),
                  onSizeGuideChanged: (guide) =>
                      setState(() => _sizeGuide = guide),
                ),
                const SizedBox(height: AdminConstants.spacingLg),
                AdminCard(
                  title: AdminStrings.details,
                  child: Column(
                    children: [
                      AdminField(
                        label: AdminStrings.productDescription,
                        child: AdminTextInput(
                          controller: _descriptionController,
                          maxLines: 3,
                        ),
                      ),
                      AdminField(
                        label: AdminStrings.productIngredients,
                        child: AdminTextInput(
                          controller: _ingredientsController,
                          maxLines: 2,
                        ),
                      ),
                      AdminField(
                        label: AdminStrings.productBenefits,
                        child: AdminTextInput(
                          controller: _benefitsController,
                          maxLines: 2,
                        ),
                      ),
                      AdminField(
                        label: AdminStrings.productUsage,
                        child: AdminTextInput(
                          controller: _usageController,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminConstants.spacingLg),
                AdminButton(label: AdminStrings.save, onPressed: _save),
                const SizedBox(height: AdminConstants.spacingLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
