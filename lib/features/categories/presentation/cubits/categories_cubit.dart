import '../../../../core/bloc/safe_cubit.dart';

import '../../data/repository/categories_repository.dart';
import '../../domain/category_import.dart';
import '../../domain/entities/category.dart';
import 'categories_state.dart';
import '../../../../core/error/admin_error.dart';

class CategoriesCubit extends SafeCubit<CategoriesState> {
  final CategoriesRepository _repository;

  CategoriesCubit(this._repository) : super(const CategoriesState());

  Future<void> loadCategories() async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(status: CategoriesStatus.loaded, categories: categories));
    } catch (e) {
      emit(state.copyWith(status: CategoriesStatus.error, errorMessage: AdminError.message(e)));
    }
  }

  Future<void> addCategory(Category category) async {
    await _repository.addCategory(category);
    await loadCategories();
  }

  /// Returns how many categories were created.
  Future<int> importCategories(String text) async {
    final categories = CategoryImport.parse(text);
    if (categories.isEmpty) return 0;
    await _repository.addCategories(categories);
    await loadCategories();
    return categories.length;
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