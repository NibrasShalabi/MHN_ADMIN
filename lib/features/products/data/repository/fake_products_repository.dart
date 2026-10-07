import '../../domain/entities/product.dart';
import '../../domain/entities/product_private.dart';
import 'products_repository.dart';

class FakeProductsRepository implements ProductsRepository {
  final List<Product> _products = [
    const Product(id: 'P-1', name: 'سيروم 1', price: 16250, stock: 40, isNew: true),
    const Product(id: 'P-2', name: 'سيروم 2', price: 17500, stock: 25),
    const Product(id: 'P-3', name: 'سيروم 3', price: 18750, stock: 0, isOrderable: false),
    const Product(id: 'P-4', name: 'سيروم 4', price: 20000, stock: 15),
  ];

  final Map<String, ProductPrivate> _private = {
    'P-1': const ProductPrivate(costPrice: 9000),
    'P-2': const ProductPrivate(costPrice: 9800),
    'P-3': const ProductPrivate(costPrice: 10500),
    'P-4': const ProductPrivate(costPrice: 11200),
  };

  @override
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_products);
  }

  @override
  Future<ProductPrivate> getPrivate(String productId) async => _private[productId] ?? ProductPrivate.empty;

  @override
  Future<Map<String, ProductPrivate>> getAllPrivate() async => Map.unmodifiable(_private);

  @override
  Future<void> addProduct(Product product, ProductPrivate private) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _products.add(product);
    _private[product.id] = private;
  }

  @override
  Future<void> updateProduct(Product product, ProductPrivate private) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) _products[index] = product;
    _private[product.id] = private;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _products.removeWhere((p) => p.id == id);
    _private.remove(id);
  }
}
