import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// One slide of the client app's home-page swiper.
///
/// [imageBytes] mirrors how [Product.images] is handled elsewhere in this
/// admin app: raw picked bytes, no upload pipeline yet. [order] is what the
/// client renders the slides by — lowest first.
class PromoBanner extends Equatable {
  final String id;
  final Uint8List? imageBytes;
  final String? title;
  final int order;

  const PromoBanner({
    required this.id,
    this.imageBytes,
    this.title,
    this.order = 0,
  });

  PromoBanner copyWith({
    Uint8List? imageBytes,
    String? title,
    int? order,
  }) {
    return PromoBanner(
      id: id,
      imageBytes: imageBytes ?? this.imageBytes,
      title: title ?? this.title,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, imageBytes, title, order];
}