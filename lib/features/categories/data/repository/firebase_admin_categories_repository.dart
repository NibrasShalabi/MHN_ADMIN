import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/admin_cache.dart';
import '../../../../core/data/catalog_version.dart';
import '../../../../core/media/image_encoder.dart';
import '../../../../core/media/media_image.dart';
import '../../../../core/media/media_service.dart';
import '../../domain/entities/category.dart';
import 'categories_repository.dart';

class FirebaseAdminCategoriesRepository implements CategoriesRepository {
  final FirebaseFirestore _db;
  final MediaService _media;

  FirebaseAdminCategoriesRepository(this._db, this._media);

  CollectionReference<Map<String, dynamic>> get _categories => _db.collection('categories');

  Future<String?> _saveImage(Category c) async =>
      (await _media.save('categories/${c.id}', [?c.image], ImageSpec.category)).firstOrNull;

  @override
  Future<List<Category>> getCategories() => AdminCache.get('FirebaseAdminCategoriesRepository.getCategories', () async {
    final snap = await _categories.get();
    return snap.docs.map(_fromDoc).toList();
  });

  @override
  Future<void> addCategory(Category category) async {
    AdminCache.clear();
    final image = await _saveImage(category);
    await CatalogVersion.commit(_db, (b) => b.set(_categories.doc(category.id), {..._toMap(category), 'imageUrl': image}));
  }

  @override
  Future<void> addCategories(List<Category> categories) async {
    AdminCache.clear();
    await CatalogVersion.commit(_db, (b) {
      for (final c in categories) {
        b.set(_categories.doc(c.id), {..._toMap(c), 'imageUrl': null});
      }
    });
  }

  /// The old picture goes once the new one is saved. A change of
  /// femaleOnly is copied onto the category's products.
  @override
  Future<void> updateCategory(Category category) async {
    AdminCache.clear();
    final before = (await _categories.doc(category.id).get()).data() ?? const {};
    final image = await _saveImage(category);
    await CatalogVersion.commit(
        _db, (b) => b.update(_categories.doc(category.id), {..._toMap(category), 'imageUrl': image}));
    await _media.removeUnused([before['imageUrl'] as String?], [image]);
    if ((before['femaleOnly'] ?? false) != category.femaleOnly) {
      await _syncProducts(category.id, category.femaleOnly);
    }
  }

  Future<void> _syncProducts(String categoryId, bool femaleOnly) async {
    final docs = (await _db.collection('products').where('categoryId', isEqualTo: categoryId).get()).docs;
    for (var i = 0; i < docs.length; i += 450) {
      final batch = _db.batch();
      for (final d in docs.skip(i).take(450)) {
        batch.update(d.reference, {'femaleOnly': femaleOnly});
      }
      await batch.commit();
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    AdminCache.clear();
    final before = (await _categories.doc(id).get()).data()?['imageUrl'] as String?;
    await CatalogVersion.commit(_db, (b) => b.delete(_categories.doc(id)));
    await _media.removeUnused([before]);
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
      image: switch (d['imageUrl']) { final String p => StoredImage(p), _ => null },
      femaleOnly: d['femaleOnly'] as bool? ?? false,
      filters: (d['filters'] as List<dynamic>? ?? [])
          .map((f) => ProductFilter(id: f['id'] as String, name: f['name'] as String))
          .toList(),
    );
  }

  /// imageUrl is written by the callers (a bucket path, after upload).
  Map<String, dynamic> _toMap(Category category) => {
        'name': category.name,
        'scope': category.scope.name,
        'supplierId': category.supplierId,
        'femaleOnly': category.femaleOnly,
        'filters': category.filters.map((f) => {'id': f.id, 'name': f.name}).toList(),
      };
}
