import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../data/repository/products_repository.dart';
import '../../domain/entities/product.dart';
import '../cubits/products_cubit.dart';
import '../cubits/products_state.dart';
import 'product_form_page.dart';
enum ProductsPricingMode { currency, points }
class ProductsPage extends StatelessWidget {
  final ProductsPricingMode pricingMode;

  const ProductsPage({super.key, this.pricingMode = ProductsPricingMode.currency});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductsCubit(GetIt.instance<ProductsRepository>())..loadProducts(),

      child: _ProductsView(pricingMode: pricingMode),
    );
  }
}

class _ProductsView extends StatefulWidget {
  final ProductsPricingMode pricingMode;

  const _ProductsView({required this.pricingMode});

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm(BuildContext context, ProductsCubit cubit, {Product? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,

          child: ProductFormPage(product: product, pricingMode: widget.pricingMode),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,###', 'ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AdminTextInput(
                controller: _searchController,
                hint: AdminStrings.searchProducts,
                onChanged: (v) => setState(() => _query = v.trim()),
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

            final products = _query.isEmpty
                ? state.products
                : state.products
                .where((p) => p.name.contains(_query))
                .toList();
            final cubit = context.read<ProductsCubit>();

            return AdminDataTable(
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
                  product.images.isEmpty
                      ? const Icon(Icons.image_outlined, color: AdminColors.textDisabled)
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                    child: Image.memory(product.images.first,
                        width: 32, height: 32, fit: BoxFit.cover),
                  ),
                  Text(product.name, style: AdminTextStyles.caption),
                  Text(
                    widget.pricingMode == ProductsPricingMode.points
                        ? '${product.price.toStringAsFixed(0)} ${AdminStrings.pointsWord}'
                        : '${currency.format(product.price)} ل.س',
                    style: AdminTextStyles.caption,
                  ),                  Text('${product.stock}', style: AdminTextStyles.caption),
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