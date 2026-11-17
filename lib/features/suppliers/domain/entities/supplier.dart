import 'package:equatable/equatable.dart';

import '../../../../core/media/media_image.dart';

/// A third-party shop with its own storefront in the app. Customers order
/// from it directly over WhatsApp; [ownerUid] is kept for the supplier
/// dashboard planned later.
class Supplier extends Equatable {
  final String id;
  final String name;
  final MediaImage? logo;
  final String description;

  /// Digits with the country code, e.g. 963912345678.
  final String phone;
  final String address;
  final String mapsUrl;
  final bool isActive;
  final String? ownerUid;

  const Supplier({
    required this.id,
    required this.name,
    this.logo,
    this.description = '',
    this.phone = '',
    this.address = '',
    this.mapsUrl = '',
    this.isActive = true,
    this.ownerUid,
  });

  @override
  List<Object?> get props => [id, name, logo, description, phone, address, mapsUrl, isActive, ownerUid];
}
