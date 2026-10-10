import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Where a tap on the banner takes the customer.
enum BannerLink {
  none('none'),
  product('product'),
  category('category'),
  deals('deals');

  final String key;
  const BannerLink(this.key);

  static BannerLink fromKey(String? key) => values.firstWhere((l) => l.key == key, orElse: () => none);

  bool get needsTarget => this == product || this == category;
}

/// One slide of the app's home swiper, shown lowest [order] first, only
/// between [startsAt] and [endsAt] when set.
class PromoBanner extends Equatable {
  final String id;
  final Uint8List? imageBytes;
  final String? title;
  final int order;
  final BannerLink link;

  /// Product or category id for [BannerLink.product] / [BannerLink.category].
  final String? linkId;
  final DateTime? startsAt;
  final DateTime? endsAt;

  const PromoBanner({
    required this.id,
    this.imageBytes,
    this.title,
    this.order = 0,
    this.link = BannerLink.none,
    this.linkId,
    this.startsAt,
    this.endsAt,
  });

  @override
  List<Object?> get props => [id, imageBytes, title, order, link, linkId, startsAt, endsAt];
}
