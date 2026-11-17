import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/catalog_version.dart';
import '../../../../core/media/image_encoder.dart';
import '../../../../core/media/media_image.dart';
import '../../../../core/media/media_service.dart';
import '../../domain/entities/supplier.dart';
import 'suppliers_repository.dart';
import '../../../../core/data/admin_cache.dart';

class FirebaseAdminSuppliersRepository implements SuppliersRepository {
  final FirebaseFirestore _db;
  final MediaService _media;

  FirebaseAdminSuppliersRepository(this._db, this._media);

  Future<String?> _logoPath(String id) async => (await _suppliers.doc(id).get()).data()?['logoUrl'] as String?;

  Future<String?> _saveLogo(Supplier s) async =>
      (await _media.save('suppliers/${s.id}', [?s.logo], ImageSpec.logo)).firstOrNull;

  CollectionReference<Map<String, dynamic>> get _suppliers => _db.collection('suppliers');

  @override
  Future<List<Supplier>> getSuppliers() => AdminCache.get('FirebaseAdminSuppliersRepository.getSuppliers', () async {
    final snap = await _suppliers.get();
    return snap.docs.map(_fromDoc).toList();
  });

  @override
  Future<void> addSupplier(Supplier supplier) async {
    AdminCache.clear();
    final logo = await _saveLogo(supplier);
    await CatalogVersion.commit(
      _db,
      (b) => b.set(
          _suppliers.doc(supplier.id), {..._toMap(supplier), 'logoUrl': logo, 'createdAt': FieldValue.serverTimestamp()}));
  }

  /// Merge keeps fields this form doesn't own (ownerUid). logoUrl is a
  /// bucket path; the old file goes once the new one is saved.
  @override
  Future<void> updateSupplier(Supplier supplier) async {
    AdminCache.clear();
    final before = await _logoPath(supplier.id);
    final logo = await _saveLogo(supplier);
    await CatalogVersion.commit(
        _db, (b) => b.set(_suppliers.doc(supplier.id), {..._toMap(supplier), 'logoUrl': logo}, SetOptions(merge: true)));
    await _media.removeUnused([before], [logo]);
  }

  @override
  Future<void> deleteSupplier(String id) async {
    AdminCache.clear();
    final before = await _logoPath(id);
    await CatalogVersion.commit(_db, (b) => b.delete(_suppliers.doc(id)));
    await _media.removeUnused([before]);
  }

  Map<String, dynamic> _toMap(Supplier s) => {
        'name': s.name,
        'description': s.description,
        'phone': s.phone,
        'address': s.address,
        'mapsUrl': s.mapsUrl,
        'isActive': s.isActive,
      };

  Supplier _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Supplier(
      id: doc.id,
      name: d['name'] as String? ?? '',
      description: d['description'] as String? ?? '',
      phone: d['phone'] as String? ?? '',
      address: d['address'] as String? ?? '',
      mapsUrl: d['mapsUrl'] as String? ?? '',
      isActive: d['isActive'] as bool? ?? true,
      ownerUid: d['ownerUid'] as String?,
      logo: switch (d['logoUrl']) { final String p => StoredImage(p), _ => null },
    );
  }
}
