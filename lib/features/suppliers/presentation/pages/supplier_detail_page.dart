import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../categories/presentation/pages/categories_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../cubits/suppliers_cubit.dart';
import '../widgets/supplier_form_panel.dart';

enum _SupplierTab { info, categories, products }

/// One supplier's storefront: its details, its categories and filters,
/// and its products — everything filed under it from one place.
class SupplierDetailPage extends StatefulWidget {
  final String supplierId;

  const SupplierDetailPage({super.key, required this.supplierId});

  @override
  State<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends State<SupplierDetailPage> {
  _SupplierTab _tab = _SupplierTab.info;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SuppliersCubit>();
    final supplier = cubit.state.suppliers.where((s) => s.id == widget.supplierId).firstOrNull;

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      appBar: AppBar(
        backgroundColor: AdminColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminColors.gold),
        title: Text(supplier?.name ?? '', style: AdminTextStyles.pageTitle),
      ),
      body: supplier == null
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AdminConstants.maxContentWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AdminConstants.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AdminOptionChips<_SupplierTab>(
                        options: _SupplierTab.values,
                        selected: _tab,
                        allowNone: false,
                        labelOf: (t) => switch (t) {
                          _SupplierTab.info => AdminStrings.supplierInfo,
                          _SupplierTab.categories => AdminStrings.navCategories,
                          _SupplierTab.products => AdminStrings.navProducts,
                        },
                        onChanged: (t) => setState(() => _tab = t ?? _tab),
                      ),
                      const SizedBox(height: AdminConstants.spacingLg),
                      switch (_tab) {
                        _SupplierTab.info => AdminCard(
                            child: SupplierFormPanel(key: ValueKey(supplier.id), supplier: supplier, cubit: cubit),
                          ),
                        _SupplierTab.categories => CategoriesPage(supplierId: supplier.id),
                        _SupplierTab.products => ProductsPage(supplierId: supplier.id),
                      },
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// Opens [SupplierDetailPage] sharing the list's cubit.
void openSupplier(BuildContext context, String supplierId) {
  final cubit = context.read<SuppliersCubit>();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(value: cubit, child: SupplierDetailPage(supplierId: supplierId)),
    ),
  );
}

