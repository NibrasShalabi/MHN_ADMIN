import '../../../../core/bloc/safe_cubit.dart';
import '../../data/repository/products_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_private.dart';
import 'products_state.dart';

/// Writes patch the list locally instead of reloading the whole
/// collection — a full reload after every save was N reads each time.
class ProductsCubit extends SafeCubit<ProductsState> {
  final ProductsRepository _repository;

  ProductsCubit(this._repository) : super(const ProductsState());

  Future<void> loadProducts() async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final products = await _repository.getProducts();
      emit(state.copyWith(status: ProductsStatus.loaded, products: products));
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<ProductPrivate> loadPrivate(String productId) => _repository.getPrivate(productId);

  Future<bool> addProduct(Product product, ProductPrivate private) => _write(
        () => _repository.addProduct(product, private),
        (list) => [...list, product],
      );

  Future<bool> updateProduct(Product product, ProductPrivate private) => _write(
        () => _repository.updateProduct(product, private),
        (list) => [for (final p in list) p.id == product.id ? product : p],
      );

  Future<void> deleteProduct(String id) => _write(
        () => _repository.deleteProduct(id),
        (list) => list.where((p) => p.id != id).toList(),
      );

  Future<bool> _write(Future<void> Function() action, List<Product> Function(List<Product>) patch) async {
    try {
      await action();
      emit(state.copyWith(products: patch(state.products)));
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }
}
