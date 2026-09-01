import '../../domain/entities/category.dart';
import 'categories_repository.dart';

class FakeCategoriesRepository implements CategoriesRepository {
  final List<Category> _categories = [
    const Category(
      id: 'C-1',
      name: 'العناية بالبشرة',
      scope: CategoryScope.store,
      filters: [
        ProductFilter(id: 'F-1', name: 'بشرة دهنية'),
        ProductFilter(id: 'F-2', name: 'بشرة جافة'),
      ],
    ),
    const Category(id: 'C-2', name: 'برامج اللياقة', scope: CategoryScope.fitness),
  ];

  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_categories);
  }

  @override
  Future<void> addCategory(Category category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _categories.add(category);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) _categories[index] = category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _categories.removeWhere((c) => c.id == id);
  }
}