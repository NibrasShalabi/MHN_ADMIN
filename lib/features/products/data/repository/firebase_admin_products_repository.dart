import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product.dart';
import '../../../presets/domain/entities/presets.dart';
import 'products_repository.dart';

class FirebaseAdminProductsRepository implements ProductsRepository {
  final FirebaseFirestore _db;

  FirebaseAdminProductsRepository(this._db);

  @override
  Future<List<Product>> getProducts() async {
    final snap = await _db.collection('products').get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(_toMap(product));
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(_toMap(product));
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  // ===== Mappers =====

  Product _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;

    // قراءة clothingSizes → sizes (Admin format)
    final clothingSizes = d['clothingSizes'] as List? ?? [];
    final sizes = Set<String>.from(
      clothingSizes.map((s) => (s as String).toUpperCase()),
    );

    // قراءة colors → colorIds (Admin format)
    final colorsList = d['colors'] as List? ?? [];
    final colorIds = Set<String>.from(
      colorsList.map((c) => (c as Map)['name'] as String? ?? ''),
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
      price: (d['price'] as num? ?? 0).toDouble(),
      costPrice: (d['costPrice'] as num?)?.toDouble(),
      shippingPrice: (d['shippingPrice'] as num?)?.toDouble(),
      supplierId: d['supplierId'] as String?,
      stock: d['stock'] as int? ?? 0,
      description: d['description'] as String? ?? '',
      ingredients: d['ingredients'] as String?,
      benefits: d['benefits'] as String?,
      usage: d['usage'] as String?,
      images: const [],
      isNew: d['isNew'] as bool? ?? false,
      isOrderable: d['isOrderable'] as bool? ?? true,
      sizes: sizes,
      colorIds: colorIds,
      sizeGuide: sizeGuide,
      discountPercentage: (d['discountPercentage'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> _toMap(Product product) {
    final clothingSizes = product.sizes
        .map((s) => s.toLowerCase())
        .where((s) => ['xs', 's', 'm', 'l', 'xl', 'xxl'].contains(s))
        .toList();

    final colors = product.colorIds.map((id) => {
      'name': id,
      'value': 0xFF000000,
    }).toList();

    return {
      'name': product.name,
      'categoryId': product.category,
      'price': product.price,
      'costPrice': product.costPrice,
      'shippingPrice': product.shippingPrice,
      'supplierId': product.supplierId,
      'stock': product.stock,
      'description': product.description,
      'ingredients': product.ingredients,
      'benefits': product.benefits,
      'usage': product.usage,
      'isNew': product.isNew,
      'isOrderable': product.isOrderable,
      'clothingSizes': clothingSizes,
      'shoeSizes': <int>[],
      'colors': colors,
      'sizeGuide': product.sizeGuide?.rows.map((r) => {
        'size': r.size,
        'measurements': r.measurements,
      }).toList() ?? [],
      'discountPercentage': product.discountPercentage,
      'imageUrls': [],
      'pricing': product.category == 'loyalty' ? 'points' : 'money',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}