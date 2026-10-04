import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/presets.dart';
import 'presets_repository.dart';

class FirebaseAdminPresetsRepository implements PresetsRepository {
  final FirebaseFirestore _db;

  FirebaseAdminPresetsRepository(this._db);

  @override
  Future<CatalogPresets> getPresets() async {
    final results = await Future.wait([
      _db.collection('sizeSets').get(),
      _db.collection('paletteColors').get(),
      _db.collection('sizeGuides').get(),
    ]);

    final sizeSets = results[0].docs.map((doc) {
      final d = doc.data();
      return SizeSet(
        id: doc.id,
        name: d['name'] as String? ?? '',
        sizes: List<String>.from(d['sizes'] as List? ?? []),
      );
    }).toList();

    final colors = results[1].docs.map((doc) {
      final d = doc.data();
      return PaletteColor(
        id: doc.id,
        name: d['name'] as String? ?? '',
        value: d['value'] as int? ?? 0xFF000000,
      );
    }).toList();

    final sizeGuides = results[2].docs.map((doc) {
      final d = doc.data();
      return SizeGuideTemplate(
        id: doc.id,
        name: d['name'] as String? ?? '',
        rows: (d['rows'] as List<dynamic>? ?? []).map((r) {
          return SizeGuideTemplateRow(
            size: r['size'] as String? ?? '',
            measurements: Map<String, String>.from(r['measurements'] as Map? ?? {}),
          );
        }).toList(),
      );
    }).toList();

    return CatalogPresets(
      sizeSets: sizeSets.isEmpty ? DefaultPresets.sizeSets : sizeSets,
      colors: colors.isEmpty ? DefaultPresets.colors : colors,
      sizeGuides: sizeGuides.isEmpty ? DefaultPresets.sizeGuides : sizeGuides,
    );
  }

  @override
  Future<void> addSizeSet(SizeSet set) async {
    await _db.collection('sizeSets').doc(set.id).set({'name': set.name, 'sizes': set.sizes});
  }

  @override
  Future<void> updateSizeSet(SizeSet set) async {
    await _db.collection('sizeSets').doc(set.id).update({'name': set.name, 'sizes': set.sizes});
  }

  @override
  Future<void> deleteSizeSet(String id) async {
    await _db.collection('sizeSets').doc(id).delete();
  }

  @override
  Future<void> addColor(PaletteColor color) async {
    await _db.collection('paletteColors').doc(color.id).set({'name': color.name, 'value': color.value});
  }

  @override
  Future<void> updateColor(PaletteColor color) async {
    await _db.collection('paletteColors').doc(color.id).update({'name': color.name, 'value': color.value});
  }

  @override
  Future<void> deleteColor(String id) async {
    await _db.collection('paletteColors').doc(id).delete();
  }

  @override
  Future<void> addSizeGuide(SizeGuideTemplate guide) async {
    await _db.collection('sizeGuides').doc(guide.id).set({
      'name': guide.name,
      'rows': guide.rows.map((r) => {'size': r.size, 'measurements': r.measurements}).toList(),
    });
  }

  @override
  Future<void> updateSizeGuide(SizeGuideTemplate guide) async {
    await _db.collection('sizeGuides').doc(guide.id).update({
      'name': guide.name,
      'rows': guide.rows.map((r) => {'size': r.size, 'measurements': r.measurements}).toList(),
    });
  }

  @override
  Future<void> deleteSizeGuide(String id) async {
    await _db.collection('sizeGuides').doc(id).delete();
  }
}