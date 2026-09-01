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
import '../../data/repository/categories_repository.dart';
import '../../domain/entities/category.dart';
import '../cubits/categories_cubit.dart';
import '../cubits/categories_state.dart';
import '../widgets/category_form_panel.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesCubit(GetIt.instance<CategoriesRepository>())..loadCategories(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  void _openForm(BuildContext context, CategoriesCubit cubit, {Category? category}) {
    showAdminSidePanel(
      context,
      title: category == null ? AdminStrings.addCategory : AdminStrings.editCategory,
      child: CategoryFormPanel(category: category, cubit: cubit),
    );
  }

  void _confirmDelete(BuildContext context, CategoriesCubit cubit, Category category) {
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
                        cubit.deleteCategory(category.id);
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
                label: AdminStrings.addCategory,
                icon: Icons.add,
                onPressed: () => _openForm(context, context.read<CategoriesCubit>()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state.status == CategoriesStatus.loading ||
                state.status == CategoriesStatus.initial) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == CategoriesStatus.error) {
              return Center(
                child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong),
              );
            }

            final categories = state.categories;
            final cubit = context.read<CategoriesCubit>();

            return AdminDataTable(
              emptyMessage: AdminStrings.noData,
              rowCount: categories.length,
              columns: const [
                AdminColumn(AdminStrings.categoryName, flex: 3),
                AdminColumn(AdminStrings.categoryScope, flex: 2),
                AdminColumn(AdminStrings.filters, flex: 2),
                AdminColumn('', flex: 1),
              ],
              cellsBuilder: (index) {
                final category = categories[index];
                return [
                  Text(category.name, style: AdminTextStyles.caption),
                  Text(category.scope.label, style: AdminTextStyles.caption),
                  Text('${category.filters.length}', style: AdminTextStyles.caption),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AdminColors.danger),
                    onPressed: () => _confirmDelete(context, cubit, category),
                  ),
                ];
              },
              onRowTap: (index) => _openForm(context, cubit, category: categories[index]),
            );
          },
        ),
      ],
    );
  }
}