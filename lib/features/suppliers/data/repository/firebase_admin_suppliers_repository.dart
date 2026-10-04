import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/supplier.dart';
import 'suppliers_repository.dart';

class FirebaseAdminSuppliersRepository implements SuppliersRepository {
  final FirebaseFirestore _db;

  FirebaseAdminSuppliersRepository(this._db);

  @override
  Future<List<Supplier>> getSuppliers() async {
    final snap = await _db.collection('suppliers').get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> addSupplier(Supplier supplier) async {
    await _db.collection('suppliers').doc(supplier.id).set({
      'name': supplier.name,
      'description': supplier.description,
      'logoUrl': null, // لاحقاً بعد Storage
    });
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    await _db.collection('suppliers').doc(supplier.id).update({
      'name': supplier.name,
      'description': supplier.description,
    });
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _db.collection('suppliers').doc(id).delete();
  }

  Supplier _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Supplier(
      id: doc.id,
      name: d['name'] as String? ?? '',
      description: d['description'] as String? ?? '',
      // logoBytes: null — الصور من Storage لاحقاً
    );
  }
}