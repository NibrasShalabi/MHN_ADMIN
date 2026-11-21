import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/media/image_encoder.dart';
import '../../../../core/media/media_service.dart';
import '../../domain/entities/payment_settings.dart';

class PaymentSettingsRepository {
  final FirebaseFirestore _db;
  final MediaService _media;

  PaymentSettingsRepository(this._db, this._media);

  DocumentReference<Map<String, dynamic>> get _doc => _db.collection('config').doc('payment_addresses');

  Future<PaymentSettings> get() async => PaymentSettings.fromMap((await _doc.get()).data() ?? const {});

  /// The QR is uploaded first; the old one is deleted once the new settings are saved.
  Future<void> save(PaymentSettings settings) async {
    final before = (await _doc.get()).data()?['sham_cash_qr'] as String?;
    final qr = (await _media.save('payments/sham_cash', [?settings.shamCashQr], ImageSpec.qr)).firstOrNull;
    await _doc.set({...settings.toMap(), 'sham_cash_qr': qr});
    await _media.removeUnused([before], [qr]);
  }
}
