import '../../domain/entities/promo_banner.dart';
import 'promo_banners_repository.dart';

class FakePromoBannersRepository implements PromoBannersRepository {
  final List<PromoBanner> _banners = [
    const PromoBanner(id: 'B-1', title: 'تخفيضات الموسم', order: 0),
    const PromoBanner(id: 'B-2', title: 'وصل حديثاً', order: 1),
  ];

  @override
  Future<List<PromoBanner>> getBanners() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sorted = [..._banners]..sort((a, b) => a.order.compareTo(b.order));
    return List.unmodifiable(sorted);
  }

  @override
  Future<void> addBanner(PromoBanner banner) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _banners.add(banner);
  }

  @override
  Future<void> updateBanner(PromoBanner banner) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _banners.indexWhere((b) => b.id == banner.id);
    if (index != -1) _banners[index] = banner;
  }

  @override
  Future<void> deleteBanner(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _banners.removeWhere((b) => b.id == id);
  }
}