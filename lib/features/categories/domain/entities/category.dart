import 'package:equatable/equatable.dart';

import '../../../../core/constants/admin_strings.dart';

enum CategoryScope { store, fitness, loyalty, supplier }

extension CategoryScopeX on CategoryScope {
  String get label => switch (this) {
    CategoryScope.store => AdminStrings.scopeStore,
    CategoryScope.fitness => AdminStrings.scopeFitness,
    CategoryScope.loyalty => AdminStrings.scopeLoyalty,
    CategoryScope.supplier => AdminStrings.scopeSupplier,
  };
}

class ProductFilter extends Equatable {
  final String id;
  final String name;

  const ProductFilter({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class Category extends Equatable {
  final String id;
  final String name;
  final CategoryScope scope;
  final List<ProductFilter> filters;

  /// Set only when [scope] is [CategoryScope.supplier] — which supplier
  /// this category belongs to, mirroring the client app.
  final String? supplierId;

  const Category({
    required this.id,
    required this.name,
    required this.scope,
    this.filters = const [],
    this.supplierId,
  });

  Category copyWith({
    String? name,
    CategoryScope? scope,
    List<ProductFilter>? filters,
    String? supplierId,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      scope: scope ?? this.scope,
      filters: filters ?? this.filters,
      supplierId: supplierId ?? this.supplierId,
    );
  }

  @override
  List<Object?> get props => [id, name, scope, filters, supplierId];
}