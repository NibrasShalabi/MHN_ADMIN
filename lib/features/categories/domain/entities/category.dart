import 'package:equatable/equatable.dart';

import '../../../../core/constants/admin_strings.dart';
import '../../../../core/media/media_image.dart';

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

  /// Picture or icon shown on the category tile; the app falls back to the
  /// name's first letter.
  final MediaImage? image;

  /// Hidden from male accounts in the app — the category, its products in
  /// every list, and search. Copied onto each product (see the products
  /// repository) so lists can filter without reading categories.
  final bool femaleOnly;

  const Category({
    required this.id,
    required this.name,
    required this.scope,
    this.filters = const [],
    this.supplierId,
    this.image,
    this.femaleOnly = false,
  });

  Category copyWith({
    String? name,
    CategoryScope? scope,
    List<ProductFilter>? filters,
    String? supplierId,
    bool? femaleOnly,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      scope: scope ?? this.scope,
      filters: filters ?? this.filters,
      supplierId: supplierId ?? this.supplierId,
      image: image,
      femaleOnly: femaleOnly ?? this.femaleOnly,
    );
  }

  @override
  List<Object?> get props => [id, name, scope, filters, supplierId, image, femaleOnly];
}