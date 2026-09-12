import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A third-party supplier with their own storefront in the client app.
/// Mirrors the client app's Supplier entity — this is the admin side of
/// the same concept, per 7.7/8.2.
class Supplier extends Equatable {
  final String id;
  final String name;
  final Uint8List? logoBytes;
  final String description;

  const Supplier({
    required this.id,
    required this.name,
    this.logoBytes,
    this.description = '',
  });

  Supplier copyWith({
    String? name,
    Uint8List? logoBytes,
    String? description,
  }) {
    return Supplier(
      id: id,
      name: name ?? this.name,
      logoBytes: logoBytes ?? this.logoBytes,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, name, logoBytes, description];
}