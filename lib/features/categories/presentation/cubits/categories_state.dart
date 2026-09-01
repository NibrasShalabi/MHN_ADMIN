import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';

enum CategoriesStatus { initial, loading, loaded, error }

class CategoriesState extends Equatable {
  final CategoriesStatus status;
  final List<Category> categories;
  final String? errorMessage;

  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.errorMessage,
  });

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<Category>? categories,
    String? errorMessage,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, errorMessage];
}