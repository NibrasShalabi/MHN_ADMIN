import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/error/admin_error.dart';
import '../../../../core/media/media_thumb.dart';
import '../../../../core/widgets/admin_text_input.dart';
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
  /// Set from a supplier's page: lists and creates only that supplier's categories.
  final String? supplierId;

  const CategoriesPage({super.key, this.supplierId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesCubit(GetIt.instance<CategoriesRepository>())..loadCategories(),
      child: _CategoriesView(supplierId: supplierId),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  final String? supplierId;

  const _CategoriesView({this.supplierId});

  void _openImport(BuildContext context, CategoriesCubit cubit) {
    showAdminSidePanel(
      context,
      title: AdminStrings.importCategories,
      child: _ImportPanel(cubit: cubit),
    );
  }

  void _openForm(BuildContext context, CategoriesCubit cubit, {Category? category}) {
    showAdminSidePanel(
      context,
      title: category == null ? AdminStrings.addCategory : AdminStrings.editCategory,
      child: CategoryFormPanel(category: category, cubit: cubit, supplierId: supplierId),
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
            if (supplierId == null)
              Builder(
                builder: (context) => AdminButton(
                  label: AdminStrings.importCategories,
                  icon: Icons.playlist_add,
                  kind: AdminButtonKind.secondary,
                  onPressed: () => _openImport(context, context.read<CategoriesCubit>()),
                ),
              ),
            const SizedBox(width: AdminConstants.spacingSm),
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

            final categories = supplierId == null
                ? state.categories
                : state.categories.where((c) => c.supplierId == supplierId).toList();
            final cubit = context.read<CategoriesCubit>();

            return AdminDataTable(
              emptyMessage: AdminStrings.noData,
              rowCount: categories.length,
              columns: const [
                AdminColumn('', flex: 1),
                AdminColumn(AdminStrings.categoryName, flex: 3),
                AdminColumn(AdminStrings.categoryScope, flex: 2),
                AdminColumn(AdminStrings.filters, flex: 2),
                AdminColumn('', flex: 1),
              ],
              cellsBuilder: (index) {
                final category = categories[index];
                return [
                  MediaThumb(image: category.image, width: 32),
                  Text(category.femaleOnly ? '${category.name}  ♀' : category.name, style: AdminTextStyles.caption),
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

/// Paste many categories at once — see CategoryImport for the format.
class _ImportPanel extends StatefulWidget {
  final CategoriesCubit cubit;

  const _ImportPanel({required this.cubit});

  @override
  State<_ImportPanel> createState() => _ImportPanelState();
}

class _ImportPanelState extends State<_ImportPanel> {
  final _text = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count = await widget.cubit.importCategories(_text.text);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(AdminStrings.categoriesImported(count))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(AdminError.message(e))));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AdminStrings.importCategoriesHint, style: AdminTextStyles.caption),
        const SizedBox(height: AdminConstants.spacingMd),
        AdminTextInput(controller: _text, maxLines: 18, hint: 'أطفال : أثاث، أحذية، ألبسة\n* نسائي : أحذية، فساتين سهرة'),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminButton(label: AdminStrings.importCategories, onPressed: _busy ? null : _import),
      ],
    );
  }
}
