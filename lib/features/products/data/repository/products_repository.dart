import '../../domain/entities/product.dart';
import '../../domain/entities/product_private.dart';

abstract class ProductsRepository {
  Future<List<Product>> getProducts();

  /// One read — only when the admin opens a product for editing.
  Future<ProductPrivate> getPrivate(String productId);

  /// Whole collection — Analytics only.
  Future<Map<String, ProductPrivate>> getAllPrivate();

  Future<void> addProduct(Product product, ProductPrivate private);
  Future<void> updateProduct(Product product, ProductPrivate private);
  Future<void> deleteProduct(String id);
}
