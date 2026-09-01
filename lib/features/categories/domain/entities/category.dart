import 'package:equatable/equatable.dart';

import '../../../../core/constants/admin_strings.dart';

enum CategoryScope { store, fitness, loyalty }

extension CategoryScopeX on CategoryScope {
  String get label => switch (this) {
    CategoryScope.store => AdminStrings.scopeStore,
    CategoryScope.fitness => AdminStrings.scopeFitness,
    CategoryScope.loyalty => AdminStrings.scopeLoyalty,
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

  const Category({
    required this.id,
    required this.name,
    required this.scope,
    this.filters = const [],
  });

  Category copyWith({
    String? name,
    CategoryScope? scope,
    List<ProductFilter>? filters,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      scope: scope ?? this.scope,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [id, name, scope, filters];
}