import 'package:equatable/equatable.dart';

import 'product.dart';

/// Admin-only product data, stored in `productsPrivate/{productId}`.
///
/// `products` is world-readable, so anything here must never live there —
/// the client app can't read this collection at all (see firestore.rules).
class ProductPrivate extends Equatable {
  final double? costPrice;

  /// Where the item is sourced from — opened by the admin, never shown to customers.
  final String? sourceUrl;

  const ProductPrivate({this.costPrice, this.sourceUrl});

  static const empty = ProductPrivate();

  @override
  List<Object?> get props => [costPrice, sourceUrl];
}

/// Average margin of products with a known cost — used by Analytics.
double averageMargin(Iterable<Product> products, Map<String, ProductPrivate> private) {
  final margins = [
    for (final p in products)
      if (private[p.id]?.costPrice case final cost? when p.price > 0) (p.price - cost) / p.price,
  ];
  return margins.isEmpty ? 0 : margins.reduce((a, b) => a + b) / margins.length;
}
