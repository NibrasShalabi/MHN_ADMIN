import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/catalog_version.dart';
import '../../domain/entities/category.dart';
import 'categories_repository.dart';

class FirebaseAdminCategoriesRepository implements CategoriesRepository {
  final FirebaseFirestore _db;

  FirebaseAdminCategoriesRepository(this._db);

  @override
  Future<List<Category>> getCategories() async {
    final snap = await _db.collection('categories').get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> addCategory(Category category) async {
    await CatalogVersion.commit(_db, (b) => b.set(_db.collection('categories').doc(category.id), _toMap(category)));
  }

  @override
  Future<void> updateCategory(Category category) async {
    await CatalogVersion.commit(_db, (b) => b.update(_db.collection('categories').doc(category.id), _toMap(category)));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await CatalogVersion.commit(_db, (b) => b.delete(_db.collection('categories').doc(id)));
  }

  // ===== Mappers =====

  Category _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Category(
      id: doc.id,
      name: d['name'] as String? ?? '',
      scope: CategoryScope.values.firstWhere(
            (s) => s.name == (d['scope'] as String? ?? 'store'),
        orElse: () => CategoryScope.store,
      ),
      supplierId: d['supplierId'] as String?,
      filters: (d['filters'] as List<dynamic>? ?? [])
          .map((f) => ProductFilter(
        id: f['id'] as String,
        name: f['name'] as String,
      ))
          .toList(),
    );
  }

  Map<String, dynamic> _toMap(Category category) => {
    'name': category.name,
    'scope': category.scope.name,
    'supplierId': category.supplierId,
    'filters': category.filters
        .map((f) => {'id': f.id, 'name': f.name})
        .toList(),
  };
}