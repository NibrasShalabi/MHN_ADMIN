import '../../domain/entities/category.dart';

abstract class CategoriesRepository {
  Future<List<Category>> getCategories();
  Future<void> addCategory(Category category);

  /// Several new categories in one write — the import.
  Future<void> addCategories(List<Category> categories);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}