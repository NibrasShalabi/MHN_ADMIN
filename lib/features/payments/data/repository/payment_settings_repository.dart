import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/payment_settings.dart';

class PaymentSettingsRepository {
  final FirebaseFirestore _db;

  PaymentSettingsRepository(this._db);

  DocumentReference<Map<String, dynamic>> get _doc => _db.collection('config').doc('payment_addresses');

  Future<PaymentSettings> get() async => PaymentSettings.fromMap((await _doc.get()).data() ?? const {});

  Future<void> save(PaymentSettings settings) => _doc.set(settings.toMap());
}
