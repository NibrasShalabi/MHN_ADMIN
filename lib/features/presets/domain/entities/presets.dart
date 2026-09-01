import 'package:equatable/equatable.dart';

/// Reusable option sets the admin defines once and then picks from.
///
/// The point of this file: adding a product should be choosing, not
/// typing. Sizes, colours and size charts are the fields that would
/// otherwise be re-entered by hand on every item — and hand-entry is what
/// produces "L" on one product and "Large" on another, which then breaks
/// filtering and comparison.

/// A named set of sizes — clothing, shoes, or anything the shop adds later.
class SizeSet extends Equatable {
  final String id;
  final String name;
  final List<String> sizes;

  const SizeSet({required this.id, required this.name, required this.sizes});

  @override
  List<Object?> get props => [id, name, sizes];
}

/// A colour in the shop's shared palette.
///
/// Picking from a palette rather than a colour wheel keeps "أسود" one
/// exact value across the catalogue instead of a dozen near-blacks.
class PaletteColor extends Equatable {
  final String id;
  final String name;

  /// 0xAARRGGBB.
  final int value;

  const PaletteColor({required this.id, required this.name, required this.value});

  @override
  List<Object?> get props => [id, name, value];
}

class SizeGuideTemplateRow extends Equatable {
  final String size;
  final Map<String, String> measurements;

  const SizeGuideTemplateRow({required this.size, required this.measurements});

  @override
  List<Object?> get props => [size, measurements];
}

/// A saved size chart — a shirt chart, a trouser chart — attachable to any
/// product instead of retyping the table each time.
class SizeGuideTemplate extends Equatable {
  final String id;
  final String name;
  final List<SizeGuideTemplateRow> rows;

  const SizeGuideTemplate({required this.id, required this.name, required this.rows});

  @override
  List<Object?> get props => [id, name, rows];
}

/// Everything the product form offers as choices.
class CatalogPresets extends Equatable {
  final List<SizeSet> sizeSets;
  final List<PaletteColor> colors;
  final List<SizeGuideTemplate> sizeGuides;

  const CatalogPresets({
    this.sizeSets = const [],
    this.colors = const [],
    this.sizeGuides = const [],
  });

  @override
  List<Object?> get props => [sizeSets, colors, sizeGuides];
}

/// Defaults shipped with the dashboard.
///
/// These are seeds, not constants — the admin edits them from the presets
/// screen, and the shop's own sets replace them over time.
abstract class DefaultPresets {
  static const List<SizeSet> sizeSets = [
    SizeSet(
      id: 'clothing_std',
      name: 'ملابس (قياسي)',
      sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
    ),
    SizeSet(
      id: 'shoes_eu',
      name: 'أحذية (أوروبي)',
      sizes: ['36', '37', '38', '39', '40', '41', '42', '43', '44', '45'],
    ),
    SizeSet(
      id: 'one_size',
      name: 'مقاس واحد',
      sizes: ['One Size'],
    ),
  ];

  static const List<PaletteColor> colors = [
    PaletteColor(id: 'black', name: 'أسود', value: 0xFF1A1A1A),
    PaletteColor(id: 'white', name: 'أبيض', value: 0xFFF5F5F5),
    PaletteColor(id: 'grey', name: 'رمادي', value: 0xFF8A8A8A),
    PaletteColor(id: 'beige', name: 'بيج', value: 0xFFD8C3A5),
    PaletteColor(id: 'wine', name: 'خمري', value: 0xFF7A0C10),
    PaletteColor(id: 'red', name: 'أحمر', value: 0xFFC62828),
    PaletteColor(id: 'pink', name: 'وردي', value: 0xFFE59BB0),
    PaletteColor(id: 'navy', name: 'كحلي', value: 0xFF1F2A44),
    PaletteColor(id: 'blue', name: 'أزرق', value: 0xFF2F6FB0),
    PaletteColor(id: 'green', name: 'أخضر', value: 0xFF3F7A56),
    PaletteColor(id: 'brown', name: 'بني', value: 0xFF6B4A32),
    PaletteColor(id: 'gold', name: 'ذهبي', value: 0xFFDE9A34),
  ];

  static const List<SizeGuideTemplate> sizeGuides = [
    SizeGuideTemplate(
      id: 'tops',
      name: 'قطع علوية',
      rows: [
        SizeGuideTemplateRow(size: 'S', measurements: {'الصدر': '88 سم', 'الطول': '64 سم'}),
        SizeGuideTemplateRow(size: 'M', measurements: {'الصدر': '96 سم', 'الطول': '66 سم'}),
        SizeGuideTemplateRow(size: 'L', measurements: {'الصدر': '104 سم', 'الطول': '68 سم'}),
        SizeGuideTemplateRow(size: 'XL', measurements: {'الصدر': '112 سم', 'الطول': '70 سم'}),
      ],
    ),
    SizeGuideTemplate(
      id: 'bottoms',
      name: 'قطع سفلية',
      rows: [
        SizeGuideTemplateRow(size: 'S', measurements: {'الخصر': '68 سم', 'طول الساق': '98 سم'}),
        SizeGuideTemplateRow(size: 'M', measurements: {'الخصر': '74 سم', 'طول الساق': '100 سم'}),
        SizeGuideTemplateRow(size: 'L', measurements: {'الخصر': '80 سم', 'طول الساق': '102 سم'}),
        SizeGuideTemplateRow(size: 'XL', measurements: {'الخصر': '88 سم', 'طول الساق': '104 سم'}),
      ],
    ),
  ];

  static const CatalogPresets all = CatalogPresets(
    sizeSets: sizeSets,
    colors: colors,
    sizeGuides: sizeGuides,
  );
}