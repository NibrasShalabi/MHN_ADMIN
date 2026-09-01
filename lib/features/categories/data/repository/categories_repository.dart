import '../../domain/entities/category.dart';

abstract class CategoriesRepository {
  Future<List<Category>> getCategories();
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}