import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/categories_repository.dart';
import '../../domain/entities/category.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepository _repository;

  CategoriesCubit(this._repository) : super(const CategoriesState());

  Future<void> loadCategories() async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(status: CategoriesStatus.loaded, categories: categories));
    } catch (e) {
      emit(state.copyWith(status: CategoriesStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> addCategory(Category category) async {
    await _repository.addCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    await loadCategories();
  }
}