import '../../domain/entities/presets.dart';
import 'presets_repository.dart';

class FakePresetsRepository implements PresetsRepository {
  final List<SizeSet> _sizeSets = [...DefaultPresets.sizeSets];
  final List<PaletteColor> _colors = [...DefaultPresets.colors];
  final List<SizeGuideTemplate> _sizeGuides = [...DefaultPresets.sizeGuides];

  @override
  Future<CatalogPresets> getPresets() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return CatalogPresets(
      sizeSets: List.unmodifiable(_sizeSets),
      colors: List.unmodifiable(_colors),
      sizeGuides: List.unmodifiable(_sizeGuides),
    );
  }

  @override
  Future<void> addSizeSet(SizeSet set) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sizeSets.add(set);
  }

  @override
  Future<void> updateSizeSet(SizeSet set) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final i = _sizeSets.indexWhere((s) => s.id == set.id);
    if (i != -1) _sizeSets[i] = set;
  }

  @override
  Future<void> deleteSizeSet(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sizeSets.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> addColor(PaletteColor color) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _colors.add(color);
  }

  @override
  Future<void> updateColor(PaletteColor color) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final i = _colors.indexWhere((c) => c.id == color.id);
    if (i != -1) _colors[i] = color;
  }

  @override
  Future<void> deleteColor(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _colors.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> addSizeGuide(SizeGuideTemplate guide) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sizeGuides.add(guide);
  }

  @override
  Future<void> updateSizeGuide(SizeGuideTemplate guide) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final i = _sizeGuides.indexWhere((g) => g.id == guide.id);
    if (i != -1) _sizeGuides[i] = guide;
  }

  @override
  Future<void> deleteSizeGuide(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sizeGuides.removeWhere((g) => g.id == id);
  }
}