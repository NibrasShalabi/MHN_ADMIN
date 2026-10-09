import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/shipping_rates.dart';

class ShippingRepository {
  final FirebaseFirestore _db;

  ShippingRepository(this._db);

  DocumentReference<Map<String, dynamic>> get _doc => _db.collection('config').doc('shipping');

  Future<ShippingRates> getRates() async => ShippingRates.fromMap((await _doc.get()).data() ?? const {});

  Future<void> saveRates(ShippingRates rates) => _doc.set(rates.toMap());
}
