import 'package:equatable/equatable.dart';

import '../../domain/entities/promo_banner.dart';

enum PromoBannersStatus { initial, loading, loaded, error }

class PromoBannersState extends Equatable {
  final PromoBannersStatus status;
  final List<PromoBanner> banners;
  final String? errorMessage;

  const PromoBannersState({
    this.status = PromoBannersStatus.initial,
    this.banners = const [],
    this.errorMessage,
  });

  PromoBannersState copyWith({
    PromoBannersStatus? status,
    List<PromoBanner>? banners,
    String? errorMessage,
  }) {
    return PromoBannersState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, banners, errorMessage];
}
