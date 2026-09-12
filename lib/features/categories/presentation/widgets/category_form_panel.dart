import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../../suppliers/data/repository/suppliers_repository.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../domain/entities/category.dart';
import '../cubits/categories_cubit.dart';

class CategoryFormPanel extends StatefulWidget {
  final Category? category;
  final CategoriesCubit cubit;

  const CategoryFormPanel({super.key, this.category, required this.cubit});

  @override
  State<CategoryFormPanel> createState() => _CategoryFormPanelState();
}

class _CategoryFormPanelState extends State<CategoryFormPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _filterNameController;
  late CategoryScope _scope;
  late List<ProductFilter> _filters;
  String? _supplierId;
  late Future<List<Supplier>> _suppliersFuture;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameController = TextEditingController(text: c?.name ?? '');
    _filterNameController = TextEditingController();
    _scope = c?.scope ?? CategoryScope.store;
    _filters = [...?c?.filters];
    _supplierId = c?.supplierId;
    _suppliersFuture = GetIt.instance<SuppliersRepository>().getSuppliers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _filterNameController.dispose();
    super.dispose();
  }

  void _addFilter() {
    final name = _filterNameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _filters = [
        ..._filters,
        ProductFilter(id: 'F-${DateTime.now().millisecondsSinceEpoch}', name: name),
      ];
      _filterNameController.clear();
    });
  }

  void _removeFilter(ProductFilter filter) {
    setState(() => _filters = _filters.where((f) => f.id != filter.id).toList());
  }

  void _save() {
    final category = Category(
      id: widget.category?.id ?? 'C-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      scope: _scope,
      filters: _filters,
      supplierId: _scope == CategoryScope.supplier ? _supplierId : null,
    );
    _isEditing ? widget.cubit.updateCategory(category) : widget.cubit.addCategory(category);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminField(
          label: AdminStrings.categoryName,
          isRequired: true,
          child: AdminTextInput(controller: _nameController),
        ),
        AdminField(
          label: AdminStrings.categoryScope,
          child: AdminOptionChips<CategoryScope>(
            options: CategoryScope.values,
            selected: _scope,
            allowNone: false,
            labelOf: (s) => s.label,
            onChanged: (s) => setState(() => _scope = s ?? _scope),
          ),
        ),
        if (_scope == CategoryScope.supplier)
          AdminField(
            label: AdminStrings.productSupplier,
            isRequired: true,
            child: FutureBuilder<List<Supplier>>(
              future: _suppliersFuture,
              builder: (context, snapshot) {
                final suppliers = snapshot.data ?? const [];
                if (suppliers.isEmpty) {
                  return Text(
                    AdminStrings.noData,
                    style: AdminTextStyles.caption.copyWith(color: AdminColors.textDisabled),
                  );
                }
                return AdminOptionChips<String>(
                  options: suppliers.map((s) => s.id).toList(),
                  selected: _supplierId,
                  allowNone: false,
                  labelOf: (id) => suppliers.firstWhere((s) => s.id == id).name,
                  onChanged: (id) => setState(() => _supplierId = id),
                );
              },
            ),
          ),
        const SizedBox(height: AdminConstants.spacingSm),
        Text(AdminStrings.filters, style: AdminTextStyles.tableHeader),
        const SizedBox(height: AdminConstants.spacingSm),
        if (_filters.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingSm),
            child: Text(AdminStrings.noData, style: AdminTextStyles.caption),
          )
        else
          Wrap(
            spacing: AdminConstants.spacingSm,
            runSpacing: AdminConstants.spacingSm,
            children: _filters
                .map((f) => AdminChip(
              label: f.name,
              isSelected: false,
              leading: const Icon(Icons.close, size: 14, color: AdminColors.textSecondary),
              onTap: () => _removeFilter(f),
            ))
                .toList(),
          ),
        const SizedBox(height: AdminConstants.spacingMd),
        Row(
          children: [
            Expanded(
              child: AdminTextInput(
                controller: _filterNameController,
                hint: AdminStrings.filterName,
              ),
            ),
            const SizedBox(width: AdminConstants.spacingSm),
            AdminButton(
              label: AdminStrings.addFilter,
              kind: AdminButtonKind.secondary,
              onPressed: _addFilter,
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminButton(label: AdminStrings.save, onPressed: _save),
      ],
    );
  }
}