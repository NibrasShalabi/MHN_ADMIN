import 'package:equatable/equatable.dart';

import '../../domain/entities/presets.dart';

enum PresetsStatus { initial, loading, loaded, error }

class PresetsState extends Equatable {
  final PresetsStatus status;
  final CatalogPresets presets;
  final Map<String, int> sizeSetUsage;
  final Map<String, int> colorUsage;
  final Map<String, int> sizeGuideUsage;
  final String? errorMessage;

  const PresetsState({
    this.status = PresetsStatus.initial,
    this.presets = const CatalogPresets(),
    this.sizeSetUsage = const {},
    this.colorUsage = const {},
    this.sizeGuideUsage = const {},
    this.errorMessage,
  });

  PresetsState copyWith({
    PresetsStatus? status,
    CatalogPresets? presets,
    Map<String, int>? sizeSetUsage,
    Map<String, int>? colorUsage,
    Map<String, int>? sizeGuideUsage,
    String? errorMessage,
  }) {
    return PresetsState(
      status: status ?? this.status,
      presets: presets ?? this.presets,
      sizeSetUsage: sizeSetUsage ?? this.sizeSetUsage,
      colorUsage: colorUsage ?? this.colorUsage,
      sizeGuideUsage: sizeGuideUsage ?? this.sizeGuideUsage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, presets, sizeSetUsage, colorUsage, sizeGuideUsage, errorMessage];
}