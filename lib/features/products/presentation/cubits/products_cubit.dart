import '../../../../core/bloc/safe_cubit.dart';
import '../../data/repository/products_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_private.dart';
import 'products_state.dart';
import '../../../../core/error/admin_error.dart';

/// One section's list, a page at a time — the whole collection was one
/// read per product on every open. Writes patch the list locally instead
/// of reloading it.
class ProductsCubit extends SafeCubit<ProductsState> {
  final ProductsRepository _repository;
  final String section;
  final ProductPricing pricing;

  String _query = '';
  Object? _cursor;

  ProductsCubit(this._repository, {this.section = ProductSection.store, this.pricing = ProductPricing.money})
      : super(const ProductsState());

  /// Starts the list over — on open and whenever the search changes.
  Future<void> loadProducts([String query = '']) async {
    _query = query;
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final batch = await _fetch(null);
      // A newer search started meanwhile — its result wins.
      if (query != _query) return;
      _cursor = batch.cursor;
      emit(state.copyWith(status: ProductsStatus.loaded, products: batch.items, hasMore: batch.cursor != null));
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.error, errorMessage: AdminError.message(e)));
    }
  }

  Future<void> loadMore() async {
    if (_cursor == null || state.loadingMore) return;
    final query = _query;
    emit(state.copyWith(loadingMore: true));
    try {
      final batch = await _fetch(_cursor);
      if (query != _query) return;
      _cursor = batch.cursor;
      emit(state.copyWith(
        products: [...state.products, ...batch.items],
        hasMore: batch.cursor != null,
        loadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(loadingMore: false, errorMessage: AdminError.message(e)));
    }
  }

  Future<ProductBatch> _fetch(Object? after) =>
      _repository.getPage(section: section, pricing: pricing, query: _query, after: after);

  Future<ProductPrivate> loadPrivate(String productId) => _repository.getPrivate(productId);

  Future<bool> addProduct(Product product, ProductPrivate private) => _write(
        () => _repository.addProduct(product, private),
        (list) => [product, ...list],
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
      emit(state.copyWith(errorMessage: AdminError.message(e)));
      return false;
    }
  }
}
