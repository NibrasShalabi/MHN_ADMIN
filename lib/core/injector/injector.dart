import 'package:get_it/get_it.dart';

import '../../features/about/data/repository/about_repository.dart';
import '../../features/about/data/repository/fake_about_repository.dart';
import '../../features/analytics/data/repository/analytics_repository.dart';
import '../../features/analytics/data/repository/fake_analytics_repository.dart';
import '../../features/categories/data/repository/categories_repository.dart';
import '../../features/categories/data/repository/fake_categories_repository.dart';
import '../../features/fitness/data/repository/fake_fitness_repository.dart';
import '../../features/fitness/data/repository/fitness_repository.dart';
import '../../features/loyalty/data/repository/fake_loyalty_repository.dart';
import '../../features/loyalty/data/repository/loyalty_repository.dart';
import '../../features/orders/data/repository/fake_orders_repository.dart';
import '../../features/orders/data/repository/orders_repository.dart';
import '../../features/presets/data/repository/fake_presets_repository.dart';
import '../../features/presets/data/repository/presets_repository.dart';
import '../../features/products/data/repository/fake_products_repository.dart';
import '../../features/products/data/repository/products_repository.dart';
import '../../features/suggestions/data/repository/fake_suggestions_repository.dart';
import '../../features/suggestions/data/repository/suggestions_repository.dart';
import '../../features/support/data/repository/fake_support_repository.dart';
import '../../features/support/data/repository/support_repository.dart';

final getIt = GetIt.instance;

/// نقطة تسجيل واحدة لكل الـ repositories. كل فيتشر جديد بضيف سطر هون بس.
void setupInjector() {
  getIt.registerLazySingleton<OrdersRepository>(() => FakeOrdersRepository());
  getIt.registerLazySingleton<ProductsRepository>(() => FakeProductsRepository());
  getIt.registerLazySingleton<CategoriesRepository>(() => FakeCategoriesRepository());
  getIt.registerLazySingleton<SuggestionsRepository>(() => FakeSuggestionsRepository());
  getIt.registerLazySingleton<SupportRepository>(() => FakeSupportRepository());
  getIt.registerLazySingleton<FitnessRepository>(() => FakeFitnessRepository());
  getIt.registerLazySingleton<PresetsRepository>(() => FakePresetsRepository());
  getIt.registerLazySingleton<LoyaltyRepository>(() => FakeLoyaltyRepository());
  getIt.registerLazySingleton<AboutRepository>(() => FakeAboutRepository());
  getIt.registerLazySingleton<AnalyticsRepository>(() => FakeAnalyticsRepository());


}