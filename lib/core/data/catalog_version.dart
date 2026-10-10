import 'package:cloud_firestore/cloud_firestore.dart';

/// The app caches the catalog (categories, suppliers, banners, products).
/// Every catalog write also stamps config/catalog, and the app drops its
/// cache when the stamp moves — so changes show without waiting hours.
abstract final class CatalogVersion {
  static void bump(FirebaseFirestore db, WriteBatch batch) => batch.set(
        db.collection('config').doc('catalog'),
        {'version': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

  /// Runs [write] and the stamp as one commit.
  static Future<void> commit(FirebaseFirestore db, void Function(WriteBatch batch) write) {
    final batch = db.batch();
    write(batch);
    bump(db, batch);
    return batch.commit();
  }
}
