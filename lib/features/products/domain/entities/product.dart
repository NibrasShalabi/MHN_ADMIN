import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../presets/domain/entities/presets.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String? category;
  final double price;
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

  const Product({
    required this.id,
    required this.name,
    this.category,
    required this.price,
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
  });

  Product copyWith({
    String? name,
    String? category,
    double? price,
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
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
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
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    price,
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
  ];
}