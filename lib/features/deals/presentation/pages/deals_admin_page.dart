import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_dropdown.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../data/repositories/deals_admin_repository.dart';
import '../../../products/data/repository/products_repository.dart';
import '../../../products/domain/entities/product.dart' as admin_product;
import '../../../products/presentation/cubits/products_cubit.dart';
import '../../../products/presentation/pages/product_form_page.dart';
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
  late final TabController _tabs = TabController(length: 2, vsync: this)..addListener(() => setState(() {}));

  // Tab 1 — an existing store product.
  List<admin_product.Product> _products = [];
  bool _loadingProducts = true;
  final _search = TextEditingController();
  admin_product.Product? _selected;

  // Tab 2 — a product made for this deal only.
  admin_product.Product? _dealProduct;

  final _discount = TextEditingController();
  final _hours = TextEditingController(text: '24');
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await GetIt.instance<ProductsRepository>().getProducts();
    if (!mounted) return;
    setState(() {
      // Deal-only products belong to their own deal; gifts are priced in points.
      _products = products.where((p) => !p.dealOnly && p.pricing == admin_product.ProductPricing.money).toList();
      _loadingProducts = false;
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    _discount.dispose();
    _hours.dispose();
    super.dispose();
  }

  admin_product.Product? get _product => _tabs.index == 0 ? _selected : _dealProduct;
  double? get _discountValue => double.tryParse(_discount.text.trim());
  int? get _hoursValue => int.tryParse(_hours.text.trim());
  bool get _canSubmit => !_submitting && _product != null && _discountValue != null && _hoursValue != null;

  Future<void> _createDealProduct() async {
    final product = await Navigator.of(context).push<admin_product.Product>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ProductsCubit(GetIt.instance<ProductsRepository>()),
          child: const ProductFormPage(dealOnly: true),
        ),
      ),
    );
    if (product != null && mounted) setState(() => _dealProduct = product);
  }

  Future<void> _submit() async {
    final product = _product!;
    setState(() => _submitting = true);
    final result = await context.read<DealsAdminCubit>().addPromotion(
          productId: product.id,
          productName: product.name,
          originalPrice: product.price,
          discountPercentage: _discountValue!,
          durationHours: _hoursValue!,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        DealsAdminResult.success => AdminStrings.dealAdded,
        DealsAdminResult.duplicatePromotion => AdminStrings.dealDuplicateError,
        DealsAdminResult.invalid => AdminStrings.dealInvalid,
        DealsAdminResult.failure => AdminStrings.dealFailed,
      }),
    ));
    if (result != DealsAdminResult.success) return;
    setState(() {
      _selected = null;
      _dealProduct = null;
      _discount.clear();
      _hours.text = '24';
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final discount = _discountValue;
    final query = _search.text.trim();
    final matches = _products.where((p) => query.isEmpty || p.name.contains(query)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AdminColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
            border: Border.all(color: AdminColors.border),
          ),
          child: TabBar(
            controller: _tabs,
            labelStyle: AdminTextStyles.body,
            unselectedLabelStyle: AdminTextStyles.caption,
            labelColor: AdminColors.gold,
            unselectedLabelColor: AdminColors.textSecondary,
            indicatorColor: AdminColors.gold,
            tabs: const [Tab(text: AdminStrings.dealTabExisting), Tab(text: AdminStrings.dealTabNew)],
          ),
        ),
        const SizedBox(height: AdminConstants.spacingMd),
        if (_tabs.index == 0) ...[
          Text(AdminStrings.dealExistingHint, style: AdminTextStyles.caption),
          const SizedBox(height: AdminConstants.spacingMd),
          if (_loadingProducts)
            const Center(child: CircularProgressIndicator())
          else ...[
            AdminTextInput(controller: _search, hint: AdminStrings.searchProducts, onChanged: (_) => setState(() {})),
            const SizedBox(height: AdminConstants.spacingSm),
            AdminField(
              label: AdminStrings.selectProduct,
              isRequired: true,
              child: AdminDropdown<admin_product.Product>(
                value: matches.contains(_selected) ? _selected : null,
                items: matches,
                labelOf: (p) => '${p.name} — ${Money.format(p.price)}',
                hint: AdminStrings.selectProduct,
                onChanged: (p) => setState(() => _selected = p),
              ),
            ),
          ],
        ] else ...[
          Text(AdminStrings.dealNewHint, style: AdminTextStyles.caption),
          const SizedBox(height: AdminConstants.spacingMd),
          if (_dealProduct case final p?)
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AdminColors.gold, size: 20),
                const SizedBox(width: AdminConstants.spacingSm),
                Expanded(child: Text('${p.name} — ${Money.format(p.price)}', style: AdminTextStyles.body)),
              ],
            )
          else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AdminButton(
                label: AdminStrings.dealCreateProduct,
                icon: Icons.add,
                kind: AdminButtonKind.secondary,
                onPressed: _createDealProduct,
              ),
            ),
          const SizedBox(height: AdminConstants.spacingMd),
        ],
        Row(
          children: [
            Expanded(
              child: AdminField(
                label: AdminStrings.dealDiscount,
                isRequired: true,
                hint: AdminStrings.dealDiscountHint,
                child: AdminTextInput(controller: _discount, hint: '70', onChanged: (_) => setState(() {})),
              ),
            ),
            const SizedBox(width: AdminConstants.spacingMd),
            Expanded(
              child: AdminField(
                label: AdminStrings.dealDuration,
                isRequired: true,
                hint: AdminStrings.dealDurationHint,
                child: AdminTextInput(controller: _hours, hint: '24', onChanged: (_) => setState(() {})),
              ),
            ),
          ],
        ),
        if (product != null && discount != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AdminConstants.spacingMd),
            child: Text(
              '${AdminStrings.dealPreview}: ${Money.format(product.price * (1 - discount / 100))}',
              style: AdminTextStyles.caption.copyWith(color: AdminColors.gold),
            ),
          ),
        AdminButton(
          label: AdminStrings.addDeal,
          icon: Icons.local_fire_department_outlined,
          onPressed: _canSubmit ? _submit : null,
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
                if (isActive && context.read<DealsAdminCubit>().state.isMissing(promotion))
                  Text(AdminStrings.dealMissingProduct, style: AdminTextStyles.caption.copyWith(color: AdminColors.danger)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      Money.format(promotion.originalPrice),
                      style: AdminTextStyles.caption.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AdminColors.textDisabled,
                      ),
                    ),
                    const SizedBox(width: AdminConstants.spacingSm),
                    Text(
                      Money.format(promotion.discountedPrice),
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