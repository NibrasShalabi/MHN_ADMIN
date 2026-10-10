import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A third-party shop with its own storefront in the app. Customers order
/// from it directly over WhatsApp; [ownerUid] is kept for the supplier
/// dashboard planned later.
class Supplier extends Equatable {
  final String id;
  final String name;
  final Uint8List? logoBytes;
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
    this.logoBytes,
    this.description = '',
    this.phone = '',
    this.address = '',
    this.mapsUrl = '',
    this.isActive = true,
    this.ownerUid,
  });

  @override
  List<Object?> get props => [id, name, logoBytes, description, phone, address, mapsUrl, isActive, ownerUid];
}
