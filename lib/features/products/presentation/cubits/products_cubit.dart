import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/products_repository.dart';
import '../../domain/entities/product.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
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

  Future<void> addProduct(Product product) async {
    await _repository.addProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    await loadProducts();
  }
}