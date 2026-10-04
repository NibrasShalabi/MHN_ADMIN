import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/promo_banner.dart';
import 'promo_banners_repository.dart';

class FirebaseAdminPromoBannersRepository implements PromoBannersRepository {
  final FirebaseFirestore _db;

  FirebaseAdminPromoBannersRepository(this._db);

  @override
  Future<List<PromoBanner>> getBanners() async {
    final snap = await _db
        .collection('banners')
        .where('isActive', isEqualTo: true)
        .get();
    final banners = snap.docs.map(_fromDoc).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return banners;
  }

  @override
  Future<void> addBanner(PromoBanner banner) async {
    await _db.collection('banners').doc(banner.id).set({
      'title': banner.title,
      'order': banner.order,
      'imageUrl': null, // لاحقاً بعد Storage
      'isActive': true,
    });
  }

  @override
  Future<void> updateBanner(PromoBanner banner) async {
    await _db.collection('banners').doc(banner.id).update({
      'title': banner.title,
      'order': banner.order,
    });
  }

  @override
  Future<void> deleteBanner(String id) async {
    await _db.collection('banners').doc(id).update({'isActive': false});
  }

  PromoBanner _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return PromoBanner(
      id: doc.id,
      title: d['title'] as String?,
      order: d['order'] as int? ?? 0,
      // imageBytes: null — الصور من Storage لاحقاً
    );
  }
}