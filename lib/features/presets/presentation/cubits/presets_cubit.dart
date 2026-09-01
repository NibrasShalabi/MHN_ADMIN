import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/data/repository/products_repository.dart';
import '../../data/repository/presets_repository.dart';
import '../../domain/entities/presets.dart';
import 'presets_state.dart';

class PresetsCubit extends Cubit<PresetsState> {
  final PresetsRepository _repository;
  final ProductsRepository _productsRepository;

  PresetsCubit(this._repository, this._productsRepository) : super(const PresetsState());

  Future<void> load() async {
    emit(state.copyWith(status: PresetsStatus.loading));
    try {
      final presets = await _repository.getPresets();
      final products = await _productsRepository.getProducts();

      final sizeSetUsage = <String, int>{};
      final colorUsage = <String, int>{};
      final sizeGuideUsage = <String, int>{};

      for (final p in products) {
        if (p.sizeSet != null) {
          sizeSetUsage.update(p.sizeSet!.id, (v) => v + 1, ifAbsent: () => 1);
        }
        for (final colorId in p.colorIds) {
          colorUsage.update(colorId, (v) => v + 1, ifAbsent: () => 1);
        }
        if (p.sizeGuide != null) {
          sizeGuideUsage.update(p.sizeGuide!.id, (v) => v + 1, ifAbsent: () => 1);
        }
      }

      emit(state.copyWith(
        status: PresetsStatus.loaded,
        presets: presets,
        sizeSetUsage: sizeSetUsage,
        colorUsage: colorUsage,
        sizeGuideUsage: sizeGuideUsage,
      ));
    } catch (e) {
      emit(state.copyWith(status: PresetsStatus.error, errorMessage: e.toString()));
    }
  }

  int sizeSetUsage(String id) => state.sizeSetUsage[id] ?? 0;
  int colorUsage(String id) => state.colorUsage[id] ?? 0;
  int sizeGuideUsage(String id) => state.sizeGuideUsage[id] ?? 0;

  Future<void> addSizeSet(SizeSet set) async {
    await _repository.addSizeSet(set);
    await load();
  }

  Future<void> updateSizeSet(SizeSet set) async {
    await _repository.updateSizeSet(set);
    await load();
  }

  Future<void> deleteSizeSet(String id) async {
    await _repository.deleteSizeSet(id);
    await load();
  }

  Future<void> addColor(PaletteColor color) async {
    await _repository.addColor(color);
    await load();
  }

  Future<void> updateColor(PaletteColor color) async {
    await _repository.updateColor(color);
    await load();
  }

  Future<void> deleteColor(String id) async {
    await _repository.deleteColor(id);
    await load();
  }

  Future<void> addSizeGuide(SizeGuideTemplate guide) async {
    await _repository.addSizeGuide(guide);
    await load();
  }

  Future<void> updateSizeGuide(SizeGuideTemplate guide) async {
    await _repository.updateSizeGuide(guide);
    await load();
  }

  Future<void> deleteSizeGuide(String id) async {
    await _repository.deleteSizeGuide(id);
    await load();
  }
}