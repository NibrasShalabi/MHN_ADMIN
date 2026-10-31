import '../../domain/entities/product.dart';
import '../../domain/entities/product_private.dart';

/// Where a product is listed, stored on it so a list is one query:
/// the store (loyalty gifts included), fitness, or one supplier.
abstract final class ProductSection {
  static const String store = 'store';
  static const String fitness = 'fitness';
  static String supplier(String id) => 'supplier:$id';
}

/// One page of a product list; [cursor] continues it (null = the end).
class ProductBatch {
  final List<Product> items;
  final Object? cursor;

  const ProductBatch(this.items, this.cursor);
}

abstract class ProductsRepository {
  /// The whole collection — Analytics and Presets only. Also backfills the
  /// search fields on older products.
  Future<List<Product>> getProducts();

  /// A page of one section's list, newest first; with [query], name matches.
  Future<ProductBatch> getPage({
    required String section,
    required ProductPricing pricing,
    String query = '',
    Object? after,
  });

  /// Store-priced products matching [query] — the pickers.
  Future<List<Product>> search(String query, {String? section});

  Future<Product?> getProduct(String id);

  /// A count aggregation — about one read per 1000 products.
  Future<int> countOutOfStock();

  /// One read — only when the admin opens a product for editing.
  Future<ProductPrivate> getPrivate(String productId);

  /// Whole collection — Analytics only.
  Future<Map<String, ProductPrivate>> getAllPrivate();

  Future<void> addProduct(Product product, ProductPrivate private);
  Future<void> updateProduct(Product product, ProductPrivate private);
  Future<void> deleteProduct(String id);
}
