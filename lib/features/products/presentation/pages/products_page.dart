import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/media/media_thumb.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../../../core/widgets/admin_load_more.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../../categories/domain/entities/category.dart';
import '../../data/repository/products_repository.dart';
import '../../domain/entities/product.dart';
import '../cubits/products_cubit.dart';
import '../cubits/products_state.dart';
import 'product_form_page.dart';
class ProductsPage extends StatelessWidget {
  final ProductPricing pricingMode;

  /// Set from the fitness section: lists and creates only products in
  /// fitness-scoped categories.
  final CategoryScope? scope;

  /// Set from a supplier's page: only that supplier's products.
  final String? supplierId;

  const ProductsPage({super.key, this.pricingMode = ProductPricing.money, this.scope, this.supplierId});

  /// Every section lists only its own products: a supplier its own, fitness
  /// its fitness products, the store everything else.
  String get _section => switch ((supplierId, scope)) {
        (final String id, _) => ProductSection.supplier(id),
        (_, CategoryScope.fitness) => ProductSection.fitness,
        _ => ProductSection.store,
      };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductsCubit(GetIt.instance<ProductsRepository>(), section: _section, pricing: pricingMode)
        ..loadProducts(),

      child: _ProductsView(pricingMode: pricingMode, scope: scope, supplierId: supplierId),
    );
  }
}

class _ProductsView extends StatefulWidget {
  final ProductPricing pricingMode;
  final CategoryScope? scope;
  final String? supplierId;

  const _ProductsView({required this.pricingMode, this.scope, this.supplierId});

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  static const Duration _debounce = Duration(milliseconds: 400);

  final _searchController = TextEditingController();
  Timer? _searchTimer;

  /// Searches on the server once typing pauses — one query per word, not per letter.
  void _onSearch(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(_debounce, () => context.read<ProductsCubit>().loadProducts(value.trim()));
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _openForm(BuildContext context, ProductsCubit cubit, {Product? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,

          child: ProductFormPage(
            product: product,
            pricingMode: widget.pricingMode,
            scope: widget.scope,
            supplierId: widget.supplierId,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AdminTextInput(
                controller: _searchController,
                hint: AdminStrings.searchProducts,
                onChanged: _onSearch,
              ),
            ),
            const SizedBox(width: AdminConstants.spacingMd),
            Builder(
              builder: (context) => AdminButton(
                label: AdminStrings.addProduct,
                icon: Icons.add,
                onPressed: () => _openForm(context, context.read<ProductsCubit>()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            if (state.status == ProductsStatus.loading ||
                state.status == ProductsStatus.initial) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == ProductsStatus.error) {
              return Center(
                child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong),
              );
            }

            final products = state.products;
            final cubit = context.read<ProductsCubit>();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminDataTable(
              emptyMessage: AdminStrings.noProducts,
              rowCount: products.length,
              columns: const [
                AdminColumn('', flex: 1),
                AdminColumn(AdminStrings.productName, flex: 3),
                AdminColumn(AdminStrings.productPrice, flex: 2),
                AdminColumn(AdminStrings.productStock, flex: 2),
                AdminColumn('', flex: 2),
              ],
              cellsBuilder: (index) {
                final product = products[index];
                return [
                  MediaThumb(image: product.images.firstOrNull, width: 32),
                  Text(product.name, style: AdminTextStyles.caption),
                  widget.pricingMode == ProductPricing.points
                      ? Text('${product.price.toStringAsFixed(0)} ${AdminStrings.pointsWord}', style: AdminTextStyles.caption)
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$${product.price.toStringAsFixed(2)}', style: AdminTextStyles.caption),
                      if (product.discountPercentage != null) ...[
                        const SizedBox(width: AdminConstants.spacingXs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AdminColors.danger,
                            borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                          ),
                          child: Text(
                            '${product.discountPercentage!.toStringAsFixed(0)}%',
                            style: AdminTextStyles.caption.copyWith(
                              color: AdminColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(product.stock?.toString() ?? '∞', style: AdminTextStyles.caption),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AdminColors.gold),
                        onPressed: () => _openForm(context, cubit, product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AdminColors.danger),
                        onPressed: () => _confirmDelete(context, cubit, product),
                      ),
                    ],
                  ),
                ];
              },
              onRowTap: (index) => _openForm(context, cubit, product: products[index]),
                ),
                AdminLoadMore(hasMore: state.hasMore, loading: state.loadingMore, onPressed: cubit.loadMore),
              ],
            );
          },
        ),
      ],
    );
  }
}
void _confirmDelete(BuildContext context, ProductsCubit cubit, Product product) {
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
                      cubit.deleteProduct(product.id);
                      Navigator.of(dialogContext).pop();
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