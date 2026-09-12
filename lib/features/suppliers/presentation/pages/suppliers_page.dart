import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../../../core/widgets/admin_side_panel.dart';
import '../../data/repository/suppliers_repository.dart';
import '../../domain/entities/supplier.dart';
import '../cubits/suppliers_cubit.dart';
import '../cubits/suppliers_state.dart';
import '../widgets/supplier_form_panel.dart';

class SuppliersPage extends StatelessWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SuppliersCubit(GetIt.instance<SuppliersRepository>())..load(),
      child: const _SuppliersView(),
    );
  }
}

class _SuppliersView extends StatelessWidget {
  const _SuppliersView();

  void _openForm(BuildContext context, SuppliersCubit cubit, {Supplier? supplier}) {
    showAdminSidePanel(
      context,
      title: supplier == null ? AdminStrings.addSupplier : AdminStrings.editSupplier,
      child: SupplierFormPanel(supplier: supplier, cubit: cubit),
    );
  }

  void _confirmDelete(BuildContext context, SuppliersCubit cubit, Supplier supplier) {
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
                        cubit.deleteSupplier(supplier.id);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Builder(
              builder: (context) => AdminButton(
                label: AdminStrings.addSupplier,
                icon: Icons.add,
                onPressed: () => _openForm(context, context.read<SuppliersCubit>()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        BlocBuilder<SuppliersCubit, SuppliersState>(
          builder: (context, state) {
            if (state.status == SuppliersStatus.loading ||
                state.status == SuppliersStatus.initial) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == SuppliersStatus.error) {
              return Center(child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong));
            }

            final suppliers = state.suppliers;
            final cubit = context.read<SuppliersCubit>();

            return AdminDataTable(
              emptyMessage: AdminStrings.noData,
              rowCount: suppliers.length,
              columns: const [
                AdminColumn('', flex: 1),
                AdminColumn(AdminStrings.supplierName, flex: 3),
                AdminColumn(AdminStrings.supplierDescription, flex: 4),
                AdminColumn('', flex: 1),
              ],
              cellsBuilder: (index) {
                final supplier = suppliers[index];
                return [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                    child: supplier.logoBytes != null
                        ? Image.memory(
                      supplier.logoBytes!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 36,
                      height: 36,
                      color: AdminColors.surfaceRaised,
                      child: const Icon(
                        Icons.storefront_outlined,
                        size: 18,
                        color: AdminColors.textDisabled,
                      ),
                    ),
                  ),
                  Text(supplier.name, style: AdminTextStyles.caption),
                  Text(
                    supplier.description,
                    style: AdminTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AdminColors.danger),
                    onPressed: () => _confirmDelete(context, cubit, supplier),
                  ),
                ];
              },
              onRowTap: (index) => _openForm(context, cubit, supplier: suppliers[index]),
            );
          },
        ),
      ],
    );
  }
}