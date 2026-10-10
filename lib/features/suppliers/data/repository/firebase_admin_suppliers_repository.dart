import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/catalog_version.dart';
import '../../domain/entities/supplier.dart';
import 'suppliers_repository.dart';

class FirebaseAdminSuppliersRepository implements SuppliersRepository {
  final FirebaseFirestore _db;

  FirebaseAdminSuppliersRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _suppliers => _db.collection('suppliers');

  @override
  Future<List<Supplier>> getSuppliers() async {
    final snap = await _suppliers.get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> addSupplier(Supplier supplier) => CatalogVersion.commit(
      _db,
      (b) => b.set(
          _suppliers.doc(supplier.id), {..._toMap(supplier), 'logoUrl': null, 'createdAt': FieldValue.serverTimestamp()}));

  /// Merge keeps fields this form doesn't own (logoUrl, ownerUid).
  @override
  Future<void> updateSupplier(Supplier supplier) =>
      CatalogVersion.commit(_db, (b) => b.set(_suppliers.doc(supplier.id), _toMap(supplier), SetOptions(merge: true)));

  @override
  Future<void> deleteSupplier(String id) => CatalogVersion.commit(_db, (b) => b.delete(_suppliers.doc(id)));

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
    );
  }
}
