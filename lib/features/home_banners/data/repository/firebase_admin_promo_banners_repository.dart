import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/catalog_version.dart';
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
    await CatalogVersion.commit(_db, (b) => b.set(_db.collection('banners').doc(banner.id), {
          ..._toMap(banner),
          'imageUrl': null, // لاحقاً بعد Storage
          'isActive': true,
        }));
  }

  @override
  Future<void> updateBanner(PromoBanner banner) async {
    await CatalogVersion.commit(_db, (b) => b.update(_db.collection('banners').doc(banner.id), _toMap(banner)));
  }

  @override
  Future<void> deleteBanner(String id) async {
    await CatalogVersion.commit(_db, (b) => b.update(_db.collection('banners').doc(id), {'isActive': false}));
  }

  Map<String, dynamic> _toMap(PromoBanner b) => {
        'title': b.title,
        'order': b.order,
        'link': b.link.key,
        'linkId': b.link.needsTarget ? b.linkId : null,
        'startsAt': b.startsAt == null ? null : Timestamp.fromDate(b.startsAt!),
        'endsAt': b.endsAt == null ? null : Timestamp.fromDate(b.endsAt!),
      };

  PromoBanner _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return PromoBanner(
      id: doc.id,
      title: d['title'] as String?,
      order: (d['order'] as num? ?? 0).toInt(),
      link: BannerLink.fromKey(d['link'] as String?),
      linkId: d['linkId'] as String?,
      startsAt: (d['startsAt'] as Timestamp?)?.toDate(),
      endsAt: (d['endsAt'] as Timestamp?)?.toDate(),
      // imageBytes: null — الصور من Storage لاحقاً
    );
  }
}