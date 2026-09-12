import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/promo_banners_repository.dart';
import '../../domain/entities/promo_banner.dart';
import 'promo_banners_state.dart';

class PromoBannersCubit extends Cubit<PromoBannersState> {
  final PromoBannersRepository _repository;

  PromoBannersCubit(this._repository) : super(const PromoBannersState());

  Future<void> loadBanners() async {
    emit(state.copyWith(status: PromoBannersStatus.loading));
    try {
      final banners = await _repository.getBanners();
      emit(state.copyWith(status: PromoBannersStatus.loaded, banners: banners));
    } catch (e) {
      emit(state.copyWith(status: PromoBannersStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> addBanner(PromoBanner banner) async {
    await _repository.addBanner(banner);
    await loadBanners();
  }

  Future<void> updateBanner(PromoBanner banner) async {
    await _repository.updateBanner(banner);
    await loadBanners();
  }

  Future<void> deleteBanner(String id) async {
    await _repository.deleteBanner(id);
    await loadBanners();
  }
}
