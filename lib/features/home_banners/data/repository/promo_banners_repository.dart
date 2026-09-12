import '../../domain/entities/promo_banner.dart';

abstract class PromoBannersRepository {
  Future<List<PromoBanner>> getBanners();
  Future<void> addBanner(PromoBanner banner);
  Future<void> updateBanner(PromoBanner banner);
  Future<void> deleteBanner(String id);
}
