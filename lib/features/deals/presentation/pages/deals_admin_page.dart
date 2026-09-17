import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../data/repositories/deals_admin_repository.dart';
import '../../../products/data/repository/products_repository.dart';
import '../../../products/domain/entities/product.dart' as admin_product;
import '../../domain/entities/deal_promotion.dart';
import '../cubits/deals_admin_cubit.dart';
import '../cubits/deals_admin_state.dart';

class DealsAdminPage extends StatelessWidget {
  const DealsAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DealsAdminCubit(GetIt.instance<DealsAdminRepository>())..load(),
      child: const _DealsAdminView(),
    );
  }
}

class _DealsAdminView extends StatelessWidget {
  const _DealsAdminView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DealsAdminCubit, DealsAdminState>(
      builder: (context, state) {
        if (state.status == DealsAdminStatus.loading || state.status == DealsAdminStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // فورم إضافة عرض
            AdminCard(
              title: AdminStrings.addDeal,
              child: _AddDealForm(),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            // العروض النشطة
            AdminCard(
              title: AdminStrings.activeDeals,
              child: state.active.isEmpty
                  ? _Empty(label: AdminStrings.noActiveDeals)
                  : _DealsList(promotions: state.active, isActive: true),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            // العروض المنتهية
            if (state.expired.isNotEmpty)
              AdminCard(
                title: AdminStrings.expiredDeals,
                child: _DealsList(promotions: state.expired, isActive: false),
              ),
          ],
        );
      },
    );
  }
}

class _AddDealForm extends StatefulWidget {
  @override
  State<_AddDealForm> createState() => _AddDealFormState();
}

class _AddDealFormState extends State<_AddDealForm> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1 — منتج موجود
  admin_product.Product? _selectedProduct;
  List<admin_product.Product> _products = [];
  bool _loadingProducts = true;

  // Tab 2 — منتج جديد
  final _newNameController = TextEditingController();
  final _newPriceController = TextEditingController();

  // مشترك
  final _discountController = TextEditingController();
  final _hoursController = TextEditingController(text: '24');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final repo = GetIt.instance<ProductsRepository>();
    final products = await repo.getProducts();
    setState(() {
      _products = products;
      _loadingProducts = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newNameController.dispose();
    _newPriceController.dispose();
    _discountController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  bool get _discountValid => double.tryParse(_discountController.text) != null;
  bool get _hoursValid => int.tryParse(_hoursController.text) != null;

  bool get _isExistingValid => _selectedProduct != null && _discountValid && _hoursValid;
  bool get _isNewValid =>
      _newNameController.text.isNotEmpty &&
          double.tryParse(_newPriceController.text) != null &&
          _discountValid &&
          _hoursValid;

  Future<void> _submit(BuildContext context) async {
    final discount = double.parse(_discountController.text);
    final hours = int.parse(_hoursController.text);
    final cubit = context.read<DealsAdminCubit>();

    late DealsAdminResult result;

    if (_tabController.index == 0) {
      result = await cubit.addPromotion(
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        originalPrice: _selectedProduct!.price,
        discountPercentage: discount,
        durationHours: hours,
      );
      if (result == DealsAdminResult.success) {
        setState(() => _selectedProduct = null);
      }
    } else {
      final price = double.parse(_newPriceController.text);
      result = await cubit.addPromotion(
        productId: 'deal_${DateTime.now().millisecondsSinceEpoch}',
        productName: _newNameController.text.trim(),
        originalPrice: price,
        discountPercentage: discount,
        durationHours: hours,
      );
      if (result == DealsAdminResult.success) {
        _newNameController.clear();
        _newPriceController.clear();
      }
    }

    if (!context.mounted) return;

    if (result == DealsAdminResult.duplicatePromotion) {

      return;
    }

    _discountController.clear();
    _hoursController.text = '24';
  }

  @override
  Widget build(BuildContext context) {
    final isExisting = _tabController.index == 0;
    final discount = double.tryParse(_discountController.text);
    final basePrice = isExisting
        ? _selectedProduct?.price
        : double.tryParse(_newPriceController.text);
    final previewPrice = basePrice != null && discount != null
        ? basePrice * (1 - discount / 100)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tabs
        Container(
          decoration: BoxDecoration(
            color: AdminColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
            border: Border.all(color: AdminColors.border),
          ),
          child: TabBar(
            controller: _tabController,
            labelStyle: AdminTextStyles.body,
            unselectedLabelStyle: AdminTextStyles.caption,
            labelColor: AdminColors.gold,
            unselectedLabelColor: AdminColors.textSecondary,
            indicatorColor: AdminColors.gold,
            tabs: const [
              Tab(text: 'منتج موجود'),
              Tab(text: 'منتج جديد'),
            ],
          ),
        ),
        const SizedBox(height: AdminConstants.spacingMd),

        // Tab 1 — منتج موجود
        if (isExisting) ...[
          if (_loadingProducts)
            const Center(child: CircularProgressIndicator())
          else
            AdminField(
              label: AdminStrings.selectProduct,
              isRequired: true,
              child: DropdownButtonFormField<admin_product.Product>(
                value: _selectedProduct,
                dropdownColor: AdminColors.surfaceRaised,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AdminColors.surfaceRaised,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AdminConstants.spacingMd,
                    vertical: AdminConstants.spacingSm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                    borderSide: const BorderSide(color: AdminColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                    borderSide: const BorderSide(color: AdminColors.border),
                  ),
                ),
                style: AdminTextStyles.body,
                hint: Text(AdminStrings.selectProduct, style: AdminTextStyles.caption),
                items: _products.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(
                    '${p.name} — \$${p.price.toStringAsFixed(2)}',
                    style: AdminTextStyles.body,
                  ),
                )).toList(),
                onChanged: (p) => setState(() => _selectedProduct = p),
              ),
            ),
        ],

        // Tab 2 — منتج جديد
        if (!isExisting)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AdminField(
                  label: AdminStrings.productName,
                  isRequired: true,
                  child: AdminTextInput(
                    controller: _newNameController,
                    hint: 'اسم المنتج',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(width: AdminConstants.spacingMd),
              Expanded(
                child: AdminField(
                  label: AdminStrings.dealOriginalPrice,
                  isRequired: true,
                  child: AdminTextInput(
                    controller: _newPriceController,
                    hint: '50.00',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: AdminConstants.spacingMd),

        // مشترك — خصم ومدة
        Row(
          children: [
            Expanded(
              child: AdminField(
                label: AdminStrings.dealDiscount,
                isRequired: true,
                hint: AdminStrings.dealDiscountHint,
                child: AdminTextInput(
                  controller: _discountController,
                  hint: '70',
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(width: AdminConstants.spacingMd),
            Expanded(
              child: AdminField(
                label: AdminStrings.dealDuration,
                isRequired: true,
                hint: AdminStrings.dealDurationHint,
                child: AdminTextInput(
                  controller: _hoursController,
                  hint: '24',
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
          ],
        ),

        if (previewPrice != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AdminConstants.spacingMd),
            child: Text(
              '${AdminStrings.dealPreview}: \$${previewPrice.toStringAsFixed(2)}',
              style: AdminTextStyles.caption.copyWith(color: AdminColors.gold),
            ),
          ),

        AdminButton(
          label: AdminStrings.addDeal,
          icon: Icons.local_fire_department_outlined,
          onPressed: (isExisting ? _isExistingValid : _isNewValid)
              ? () => _submit(context)
              : null,
        ),
      ],
    );
  }
}

class _DealsList extends StatelessWidget {
  final List<DealPromotion> promotions;
  final bool isActive;

  const _DealsList({required this.promotions, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: promotions.map((p) => _DealRow(promotion: p, isActive: isActive)).toList(),
    );
  }
}

class _DealRow extends StatelessWidget {
  final DealPromotion promotion;
  final bool isActive;

  const _DealRow({required this.promotion, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final remaining = promotion.remaining;
    final h = remaining.inHours.toString().padLeft(2, '0');
    final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: AdminConstants.spacingSm),
      padding: const EdgeInsets.all(AdminConstants.spacingMd),
      decoration: BoxDecoration(
        color: AdminColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
        border: Border.all(
          color: isActive ? AdminColors.primary.withValues(alpha: 0.4) : AdminColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promotion.productName, style: AdminTextStyles.body),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '\$${promotion.originalPrice.toStringAsFixed(2)}',
                      style: AdminTextStyles.caption.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AdminColors.textDisabled,
                      ),
                    ),
                    const SizedBox(width: AdminConstants.spacingSm),
                    Text(
                      '\$${promotion.discountedPrice.toStringAsFixed(2)}',
                      style: AdminTextStyles.caption.copyWith(color: AdminColors.gold),
                    ),
                    const SizedBox(width: AdminConstants.spacingSm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AdminColors.primary,
                        borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                      ),
                      child: Text(
                        '${promotion.discountPercentage.toStringAsFixed(0)}%',
                        style: AdminTextStyles.caption.copyWith(color: AdminColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isActive) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(AdminStrings.dealTimeLeft, style: AdminTextStyles.caption),
                Text(
                  '$h:$m',
                  style: AdminTextStyles.body.copyWith(
                    color: AdminColors.warning,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(width: AdminConstants.spacingMd),
            AdminButton(
              label: AdminStrings.cancel,
              kind: AdminButtonKind.danger,
              onPressed: () => context.read<DealsAdminCubit>().cancelPromotion(promotion.id),
            ),
          ] else
            Text(
              AdminStrings.dealExpired,
              style: AdminTextStyles.caption.copyWith(color: AdminColors.textDisabled),
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String label;
  const _Empty({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingLg),
      child: Center(child: Text(label, style: AdminTextStyles.caption)),
    );
  }
}