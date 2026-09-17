import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../presets/domain/entities/presets.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String? category;
  final double price;

  /// What the item costs the business, per 8.2 — admin-only. Never sent
  /// in anything the client app reads; only used here to compute margin
  /// and net profit in Analytics.
  final double? costPrice;

  /// Per-product shipping cost, separate from [price] — optional, most
  /// products won't set it (flat/negotiated delivery fee applies instead).
  final double? shippingPrice;

  /// Set directly on the product (per 8.2), independent of whether its
  /// category is supplier-scoped — the more precise, always-available
  /// signal Analytics uses to attribute sales to a supplier.
  final String? supplierId;

  final int stock;
  final String description;
  final String? ingredients;
  final String? benefits;
  final String? usage;
  final List<Uint8List> images;
  final bool isNew;
  final bool isOrderable;
  final SizeSet? sizeSet;
  final Set<String> sizes;
  final Set<String> colorIds;
  final SizeGuideTemplate? sizeGuide;
  final double? discountPercentage;

  const Product({
    required this.id,
    required this.name,
    this.category,
    required this.price,
    this.costPrice,
    this.shippingPrice,
    this.supplierId,
    required this.stock,
    this.description = '',
    this.ingredients,
    this.benefits,
    this.usage,
    this.images = const [],
    this.isNew = false,
    this.isOrderable = true,
    this.sizeSet,
    this.sizes = const {},
    this.colorIds = const {},
    this.sizeGuide,
    this.discountPercentage,
  });

  Product copyWith({
    String? name,
    String? category,
    double? price,
    double? costPrice,
    double? shippingPrice,
    String? supplierId,
    int? stock,
    String? description,
    String? ingredients,
    String? benefits,
    String? usage,
    List<Uint8List>? images,
    bool? isNew,
    bool? isOrderable,
    SizeSet? sizeSet,
    Set<String>? sizes,
    Set<String>? colorIds,
    SizeGuideTemplate? sizeGuide,
    double? discountPercentage,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      shippingPrice: shippingPrice ?? this.shippingPrice,
      supplierId: supplierId ?? this.supplierId,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      benefits: benefits ?? this.benefits,
      usage: usage ?? this.usage,
      images: images ?? this.images,
      isNew: isNew ?? this.isNew,
      isOrderable: isOrderable ?? this.isOrderable,
      sizeSet: sizeSet ?? this.sizeSet,
      sizes: sizes ?? this.sizes,
      colorIds: colorIds ?? this.colorIds,
      sizeGuide: sizeGuide ?? this.sizeGuide,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    price,
    costPrice,
    shippingPrice,
    supplierId,
    stock,
    description,
    ingredients,
    benefits,
    usage,
    images,
    isNew,
    isOrderable,
    sizeSet,
    sizes,
    colorIds,
    sizeGuide,
    discountPercentage,
  ];
}