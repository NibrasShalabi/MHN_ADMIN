import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

enum ProductsStatus { initial, loading, loaded, error }

class ProductsState extends Equatable {
  final ProductsStatus status;
  final List<Product> products;
  final String? errorMessage;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    String? errorMessage,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, errorMessage];
}