import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/catalog_version.dart';
import '../../../../core/media/image_encoder.dart';
import '../../../../core/media/media_image.dart';
import '../../../../core/media/media_service.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_private.dart';
import '../../../presets/domain/entities/presets.dart';
import 'products_repository.dart';
import '../../../../core/data/admin_cache.dart';
import '../../../../core/data/search_keys.dart';

class FirebaseAdminProductsRepository implements ProductsRepository {
  final FirebaseFirestore _db;
  final MediaService _media;

  FirebaseAdminProductsRepository(this._db, this._media);

  /// The image paths a product holds now — read before a change so the
  /// files it drops can be deleted after.
  Future<List<String>> _imagePaths(String id) async =>
      [...?((await _products.doc(id).get()).data()?['imageUrls'] as List?)?.cast<String>()];

  static const String _private = 'productsPrivate';
  static const int _pageSize = 50;
  static const int _searchLimit = 20;

  CollectionReference<Map<String, dynamic>> get _products => _db.collection('products');

  /// What a list shows: one pricing, never deal-only products.
  Query<Map<String, dynamic>> _listed({String? section, ProductPricing pricing = ProductPricing.money}) {
    var q = _products.where('pricing', isEqualTo: pricing.name).where('dealOnly', isEqualTo: false);
    if (section != null) q = q.where('section', isEqualTo: section);
    return q;
  }

  /// Browsing is newest first (one composite index); a search skips the
  /// ordering so it needs no index of its own.
  @override
  Future<ProductBatch> getPage({
    required String section,
    required ProductPricing pricing,
    String query = '',
    Object? after,
  }) async {
    final key = SearchKeys.keyOf(query);
    var q = _listed(section: section, pricing: pricing);
    q = key == null ? q.orderBy('createdAt', descending: true) : q.where('searchKeys', arrayContains: key);
    if (after is DocumentSnapshot) q = q.startAfterDocument(after);
    final snap = await q.limit(_pageSize).get();
    return ProductBatch(
      [for (final d in snap.docs) if (key == null || SearchKeys.matches('${d.data()['name']}', query)) _fromDoc(d)],
      snap.docs.length == _pageSize ? snap.docs.last : null,
    );
  }

  @override
  Future<List<Product>> search(String query, {String? section}) async {
    final key = SearchKeys.keyOf(query);
    if (key == null) return const [];
    final snap = await _listed(section: section).where('searchKeys', arrayContains: key).limit(_searchLimit).get();
    return [for (final d in snap.docs) if (SearchKeys.matches('${d.data()['name']}', query)) _fromDoc(d)];
  }

  @override
  Future<Product?> getProduct(String id) async {
    final doc = await _products.doc(id).get();
    return doc.exists ? _fromDoc(doc) : null;
  }

  @override
  Future<int> countOutOfStock() =>
      AdminCache.get('FirebaseAdminProductsRepository.countOutOfStock', () async {
        final agg = await _products.where('stock', isEqualTo: 0).count().get();
        return agg.count ?? 0;
      });

  @override
  Future<List<Product>> getProducts() => AdminCache.get('FirebaseAdminProductsRepository.getProducts', () async {
    final snap = await _db.collection('products').get();
    await _migrateLegacyCostPrices(snap.docs);
    await _migrateLegacyColors(snap.docs);
    await _backfillListFields(snap.docs);
    return snap.docs.map(_fromDoc).toList();
  });

  @override
  Future<ProductPrivate> getPrivate(String productId) async {
    final doc = await _db.collection(_private).doc(productId).get();
    return doc.exists ? _privateFromMap(doc.data()!) : ProductPrivate.empty;
  }

  @override
  Future<Map<String, ProductPrivate>> getAllPrivate() => AdminCache.get('FirebaseAdminProductsRepository.getAllPrivate', () async {
    final snap = await _db.collection(_private).get();
    return {for (final doc in snap.docs) doc.id: _privateFromMap(doc.data())};
  });

  @override
  Future<void> addProduct(Product product, ProductPrivate private) async {
    AdminCache.clear();
    final images = await _media.save('products/${product.id}', product.images, ImageSpec.product);
    final batch = _db.batch()
      ..set(_db.collection('products').doc(product.id), {
        ...await _toMap(product),
        // Bucket paths, not URLs — see MediaConfig.
        'imageUrls': images,
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..set(_db.collection(_private).doc(product.id), _privateToMap(private));
    CatalogVersion.bump(_db, batch);
    await batch.commit();
  }

  /// Leaves createdAt untouched, so an edited product doesn't look new.
  /// Images are uploaded first and the dropped ones deleted only after the
  /// document is saved — a failed save never loses a picture.
  @override
  Future<void> updateProduct(Product product, ProductPrivate private) async {
    AdminCache.clear();
    final before = await _imagePaths(product.id);
    final images = await _media.save('products/${product.id}', product.images, ImageSpec.product);
    final batch = _db.batch()
      ..update(_db.collection('products').doc(product.id), {
        ...await _toMap(product),
        'imageUrls': images,
        'costPrice': FieldValue.delete(),
        // Replaced by 'sizes'.
        'clothingSizes': FieldValue.delete(),
        'shoeSizes': FieldValue.delete(),
      })
      ..set(_db.collection(_private).doc(product.id), _privateToMap(private), SetOptions(merge: true));
    CatalogVersion.bump(_db, batch);
    await batch.commit();
    await _media.removeUnused(before, images);
  }

  @override
  Future<void> deleteProduct(String id) async {
    AdminCache.clear();
    final before = await _imagePaths(id);
    final batch = _db.batch()
      ..delete(_db.collection('products').doc(id))
      ..delete(_db.collection(_private).doc(id));
    CatalogVersion.bump(_db, batch);
    await batch.commit();
    await _media.removeUnused(before);
  }

  /// One-time, self-healing: older products kept costPrice in the public
  /// doc. Moves it to productsPrivate the first time the list loads.
  Future<void> _migrateLegacyCostPrices(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    AdminCache.clear();
    final legacy = docs.where((d) => d.data().containsKey('costPrice')).toList();
    if (legacy.isEmpty) return;

    // 2 writes per product, Firestore caps a batch at 500.
    for (var i = 0; i < legacy.length; i += 200) {
      final batch = _db.batch();
      for (final doc in legacy.skip(i).take(200)) {
        final cost = (doc.data()['costPrice'] as num?)?.toDouble();
        if (cost != null) {
          batch.set(_db.collection(_private).doc(doc.id), {'costPrice': cost}, SetOptions(merge: true));
        }
        batch.update(doc.reference, {'costPrice': FieldValue.delete()});
      }
      await batch.commit();
    }
  }

  ProductPrivate _privateFromMap(Map<String, dynamic> d) => ProductPrivate(
        costPrice: (d['costPrice'] as num?)?.toDouble(),
        sourceUrl: d['sourceUrl'] as String?,
      );

  Map<String, dynamic> _privateToMap(ProductPrivate p) => {
        'costPrice': p.costPrice,
        'sourceUrl': p.sourceUrl,
      };

  // ===== Mappers =====

  Product _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;

    // 'sizes' holds any size set's values; older products split them by kind.
    final sizes = <String>{
      for (final s in d['sizes'] as List? ?? const []) '$s',
      if (d['sizes'] == null) ...[
        for (final s in d['clothingSizes'] as List? ?? const []) '$s'.toUpperCase(),
        for (final s in d['shoeSizes'] as List? ?? const []) '$s',
      ],
    };

    // قراءة colors → colorIds (Admin format)
    final colorsList = d['colors'] as List? ?? [];
    final colorIds = Set<String>.from(
      colorsList.map((c) => (c as Map)['id'] as String? ?? c['name'] as String? ?? ''),
    );

    // قراءة sizeGuide
    final sizeGuideList = d['sizeGuide'] as List? ?? [];
    final sizeGuide = sizeGuideList.isEmpty
        ? null
        : SizeGuideTemplate(
      id: doc.id,
      name: '',
      rows: sizeGuideList.map((r) => SizeGuideTemplateRow(
        size: r['size'] as String? ?? '',
        measurements: Map<String, String>.from(r['measurements'] as Map? ?? {}),
      )).toList(),
    );

    return Product(
      id: doc.id,
      name: d['name'] as String? ?? '',
      category: d['categoryId'] as String?,
      filterId: d['filterId'] as String?,
      pricing: d['pricing'] == 'points' ? ProductPricing.points : ProductPricing.money,
      price: (d['price'] as num? ?? 0).toDouble(),
      shippingPrice: (d['shippingPrice'] as num?)?.toDouble(),
      supplierId: d['supplierId'] as String?,
      stock: d['stock'] as int? ?? 0,
      description: d['description'] as String? ?? '',
      ingredients: d['ingredients'] as String?,
      benefits: d['benefits'] as String?,
      usage: d['usage'] as String?,
      images: [for (final p in (d['imageUrls'] as List?) ?? const []) StoredImage(p as String)],
      isNew: d['isNew'] as bool? ?? false,
      isOrderable: d['isOrderable'] as bool? ?? true,
      sizes: sizes,
      // Only the id survives a save; the form swaps in the full preset.
      sizeSet: switch (d['sizeSetId']) {
        final String id => SizeSet(id: id, name: '', sizes: sizes.toList()),
        _ => null,
      },
      colorIds: colorIds,
      sizeGuide: sizeGuide,
      discountPercentage: (d['discountPercentage'] as num?)?.toDouble(),
      dealOnly: d['dealOnly'] as bool? ?? false,
    );
  }

  /// The shop's palette (saved colours over the defaults), read once.
  Future<Map<String, PaletteColor>>? _paletteFuture;
  Future<Map<String, PaletteColor>> _palette() => _paletteFuture ??= _db.collection('paletteColors').get().then((snap) => {
        for (final c in DefaultPresets.all.colors) c.id: c,
        for (final d in snap.docs)
          d.id: PaletteColor(id: d.id, name: d.data()['name'] as String? ?? d.id, value: d.data()['value'] as int? ?? 0xFF8A8A8A),
      });

  /// What the app shows: the Arabic name and the real swatch, plus the id
  /// the dashboard edits by.
  Future<List<Map<String, dynamic>>> _colorsToMap(Iterable<String> ids) async {
    final palette = await _palette();
    return [
      for (final id in ids) {'id': id, 'name': palette[id]?.name ?? id, 'value': palette[id]?.value ?? 0xFF8A8A8A},
    ];
  }

  /// One-time, self-healing: older products stored the colour id as its
  /// name with a black swatch. Rewrites them the first time the list loads.
  Future<void> _migrateLegacyColors(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    AdminCache.clear();
    final legacy = [
      for (final d in docs)
        if ((d.data()['colors'] as List? ?? const []).any((c) => (c as Map)['id'] == null)) d,
    ];
    for (var i = 0; i < legacy.length; i += 400) {
      final batch = _db.batch();
      for (final doc in legacy.skip(i).take(400)) {
        final ids = (doc.data()['colors'] as List).map((c) => (c as Map)['name'] as String? ?? '');
        batch.update(doc.reference, {'colors': await _colorsToMap(ids)});
      }
      CatalogVersion.bump(_db, batch);
      await batch.commit();
    }
  }

  /// Read from the category on every save, so a product follows it:
  /// where it is listed, and whether male accounts see it.
  Future<Map<String, dynamic>> _fromCategory(String? categoryId) async {
    final category = categoryId == null ? null : (await _db.collection('categories').doc(categoryId).get()).data();
    return {'section': _section(category), 'femaleOnly': category?['femaleOnly'] ?? false};
  }

  String _section(Map<String, dynamic>? category) => switch (category?['scope']) {
        'fitness' => ProductSection.fitness,
        'supplier' => ProductSection.supplier('${category!['supplierId']}'),
        _ => ProductSection.store,
      };

  /// One-time, self-healing: products saved before paged lists lack the
  /// fields those queries filter on. Written the first time the whole list
  /// loads (opening Analytics or Presets once).
  Future<void> _backfillListFields(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    const fields = ['section', 'femaleOnly', 'searchKeys', 'pricing', 'dealOnly', 'createdAt'];
    final legacy = docs.where((d) => fields.any((f) => d.data()[f] == null)).toList();
    if (legacy.isEmpty) return;
    AdminCache.clear();
    final categories = {for (final c in (await _db.collection('categories').get()).docs) c.id: c.data()};
    for (var i = 0; i < legacy.length; i += 400) {
      final batch = _db.batch();
      for (final doc in legacy.skip(i).take(400)) {
        final d = doc.data();
        batch.update(doc.reference, {
          'section': _section(categories[d['categoryId']]),
          'femaleOnly': categories[d['categoryId']]?['femaleOnly'] ?? false,
          'searchKeys': SearchKeys.of('${d['name'] ?? ''}'),
          'pricing': d['pricing'] ?? ProductPricing.money.name,
          'dealOnly': d['dealOnly'] ?? false,
          if (d['createdAt'] == null) 'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  Future<Map<String, dynamic>> _toMap(Product product) async {
    final colors = await _colorsToMap(product.colorIds);
    // In the set's own order (S before M, 1-2 before 3-4), not tap order.
    final sizes = [
      ...?product.sizeSet?.sizes.where(product.sizes.contains),
      ...product.sizes.where((s) => !(product.sizeSet?.sizes.contains(s) ?? false)),
    ];

    return {
      'name': product.name,
      'categoryId': product.category,
      'filterId': product.filterId,
      'price': product.price,
      'shippingPrice': product.shippingPrice,
      'supplierId': product.supplierId,
      'stock': product.stock,
      'description': product.description,
      'ingredients': product.ingredients,
      'benefits': product.benefits,
      'usage': product.usage,
      'isNew': product.isNew,
      'isOrderable': product.isOrderable,
      'dealOnly': product.dealOnly,
      'sizes': sizes,
      'sizeSetId': product.sizeSet?.id,
      'colors': colors,
      'sizeGuide': product.sizeGuide?.rows.map((r) => {
        'size': r.size,
        'measurements': r.measurements,
      }).toList() ?? [],
      'discountPercentage': product.discountPercentage,
      'pricing': product.pricing.name,
      ...await _fromCategory(product.category),
      'searchKeys': SearchKeys.of(product.name),
    };
  }
}