import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
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
import '../../../categories/data/repository/categories_repository.dart';
import '../../../categories/domain/entities/category.dart';
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
  late final TextEditingController _priceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _shippingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _ingredientsController;
  late final TextEditingController _benefitsController;
  late final TextEditingController _usageController;
  late final TextEditingController _discountController;

  late List<Uint8List> _images;
  late bool _isNew;
  late bool _isOrderable;
  SizeSet? _sizeSet;
  late Set<String> _sizes;
  late Set<String> _colorIds;
  SizeGuideTemplate? _sizeGuide;
  String? _categoryId;
  late Future<List<Category>> _categoriesFuture;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(
      text: p == null ? '' : p.price.toStringAsFixed(0),
    );
    _costPriceController = TextEditingController(
      text: p?.costPrice == null ? '' : p!.costPrice!.toStringAsFixed(0),
    );
    _shippingPriceController = TextEditingController(
      text: p?.shippingPrice == null ? '' : p!.shippingPrice!.toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: p == null ? '' : p.stock.toString(),
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _ingredientsController = TextEditingController(text: p?.ingredients ?? '');
    _benefitsController = TextEditingController(text: p?.benefits ?? '');
    _usageController = TextEditingController(text: p?.usage ?? '');
    _discountController = TextEditingController(
      text: p?.discountPercentage == null ? '' : p!.discountPercentage!.toStringAsFixed(0),
    );
    _images = [...?p?.images];
    _isNew = p?.isNew ?? false;
    _isOrderable = p?.isOrderable ?? true;
    _sizeSet = p?.sizeSet;
    _sizes = {...?p?.sizes};
    _colorIds = {...?p?.colorIds};
    _sizeGuide = p?.sizeGuide;
    _categoryId = null;
    _categoriesFuture = GetIt.instance<CategoriesRepository>().getCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _shippingPriceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _benefitsController.dispose();
    _usageController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  /// ترقيم تلقائي عند الكتابة — كل سطر بيصير رقم. سطر
  void _applyNumbering(TextEditingController controller) {
    final text = controller.text;
    final lines = text.split('\n');
    final result = <String>[];
    int counter = 1;
    for (final line in lines) {
      final stripped = line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
      if (stripped.isEmpty) {
        result.add('');
      } else {
        result.add('$counter. $stripped');
        counter++;
      }
    }
    final formatted = result.join('\n');
    if (formatted != text) {
      controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _save() {
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final costPrice = double.tryParse(_costPriceController.text.trim());
    final shippingPrice = double.tryParse(_shippingPriceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final discountPercentage = double.tryParse(_discountController.text.trim());

    final product = Product(
      id: widget.product?.id ?? 'P-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _categoryId,
      price: price,
      costPrice: costPrice,
      shippingPrice: shippingPrice,
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
      supplierId: null,
      discountPercentage: discountPercentage,
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
                        context.read<ProductsCubit>().deleteProduct(widget.product!.id);
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
          constraints: const BoxConstraints(maxWidth: AdminConstants.maxContentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AdminConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== معلومات أساسية =====
                AdminCard(
                  title: AdminStrings.basicInfo,
                  child: Column(
                    children: [
                      AdminField(
                        label: AdminStrings.productName,
                        isRequired: true,
                        child: AdminTextInput(controller: _nameController),
                      ),
                      // قائمة منسدلة للأقسام
                      AdminField(
                        label: AdminStrings.productCategory,
                        child: FutureBuilder<List<Category>>(
                          future: _categoriesFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const CircularProgressIndicator();
                            final categories = snapshot.data!;
                            final validId = categories.any((c) => c.id == _categoryId)
                                ? _categoryId
                                : null;
                            return DropdownButtonFormField<String>(
                              value: validId,
                              dropdownColor: AdminColors.surface,
                              style: AdminTextStyles.body,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AdminColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AdminColors.gold),
                                ),
                              ),
                              hint: Text(AdminStrings.selectCategory, style: AdminTextStyles.caption),
                              items: categories
                                  .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name, style: AdminTextStyles.body),
                              ))
                                  .toList(),
                              onChanged: (id) => setState(() => _categoryId = id),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AdminStrings.productIsNew, style: AdminTextStyles.label),
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
                                Text(AdminStrings.productOrderable, style: AdminTextStyles.label),
                                Text(AdminStrings.productOrderableHint, style: AdminTextStyles.caption),
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

                // ===== التسعير والمخزون =====
                AdminCard(
                  title: AdminStrings.pricingAndStock,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
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
                              label: AdminStrings.productCostPrice,
                              child: AdminTextInput(
                                controller: _costPriceController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AdminConstants.spacingMd),
                      Row(
                        children: [
                          Expanded(
                            child: AdminField(
                              label: AdminStrings.productShippingPrice,
                              child: AdminTextInput(
                                controller: _shippingPriceController,
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
                    ],
                  ),
                ),
                const SizedBox(height: AdminConstants.spacingLg),

                // ===== الصور =====
                AdminCard(
                  title: AdminStrings.productImages,
                  child: AdminImagePicker(
                    images: _images,
                    onChanged: (imgs) => setState(() => _images = imgs),
                  ),
                ),
                const SizedBox(height: AdminConstants.spacingLg),

                // ===== المتغيرات =====
                ProductVariantsSection(
                  presets: _presets,
                  sizeSet: _sizeSet,
                  selectedSizes: _sizes,
                  selectedColorIds: _colorIds,
                  sizeGuide: _sizeGuide,
                  onSizeSetChanged: (set) => setState(() => _sizeSet = set),
                  onSizesChanged: (sizes) => setState(() => _sizes = sizes),
                  onColorsChanged: (ids) => setState(() => _colorIds = ids),
                  onSizeGuideChanged: (guide) => setState(() => _sizeGuide = guide),
                ),
                const SizedBox(height: AdminConstants.spacingLg),

                // ===== التفاصيل (مع ترقيم تلقائي) =====
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
                          maxLines: 5,
                          onChanged: (_) => _applyNumbering(_ingredientsController),
                        ),
                      ),
                      AdminField(
                        label: AdminStrings.productBenefits,
                        child: AdminTextInput(
                          controller: _benefitsController,
                          maxLines: 5,
                          onChanged: (_) => _applyNumbering(_benefitsController),
                        ),
                      ),
                      AdminField(
                        label: AdminStrings.productUsage,
                        child: AdminTextInput(
                          controller: _usageController,
                          maxLines: 5,
                          onChanged: (_) => _applyNumbering(_usageController),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminConstants.spacingLg),

                // ===== الخصم =====
                AdminCard(
                  title: AdminStrings.productDiscount,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AdminField(
                        label: AdminStrings.dealDiscount,
                        hint: AdminStrings.productDiscountHint,
                        child: AdminTextInput(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          hint: '0 - 100',
                        ),
                      ),
                      if (double.tryParse(_discountController.text) != null &&
                          double.tryParse(_priceController.text) != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AdminConstants.spacingSm),
                          child: Text(
                            '${AdminStrings.dealPreview}: \$${(double.parse(_priceController.text) * (1 - double.parse(_discountController.text) / 100)).toStringAsFixed(2)}',
                            style: AdminTextStyles.caption.copyWith(color: AdminColors.gold),
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