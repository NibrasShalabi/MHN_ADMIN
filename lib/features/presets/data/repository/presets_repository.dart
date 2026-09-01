import '../../domain/entities/presets.dart';

abstract class PresetsRepository {
  Future<CatalogPresets> getPresets();

  Future<void> addSizeSet(SizeSet set);
  Future<void> updateSizeSet(SizeSet set);
  Future<void> deleteSizeSet(String id);

  Future<void> addColor(PaletteColor color);
  Future<void> updateColor(PaletteColor color);
  Future<void> deleteColor(String id);

  Future<void> addSizeGuide(SizeGuideTemplate guide);
  Future<void> updateSizeGuide(SizeGuideTemplate guide);
  Future<void> deleteSizeGuide(String id);
}