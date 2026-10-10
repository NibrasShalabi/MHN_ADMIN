import '../../features/messages/data/repository/broadcasts_repository.dart';
import '../../features/messages/data/repository/customer_messages.dart';
import '../../features/payments/data/repository/payment_settings_repository.dart';
import '../../features/shipping/data/repository/shipping_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

import '../../features/analytics/data/repository/analytics_repository.dart';
import '../../features/analytics/data/repository/fake_analytics_repository.dart';
import '../../features/analytics/data/repository/firebase_analytics_repository.dart';
import '../../features/auth/data/repository/auth_repository.dart';
import '../../features/auth/data/repository/firebase_admin_auth_repository.dart';
import '../../features/categories/data/repository/categories_repository.dart';
import '../../features/categories/data/repository/firebase_admin_categories_repository.dart';
import '../../features/deals/data/repositories/deals_admin_repository.dart';
import '../../features/deals/data/repositories/firebase_admin_deals_repository.dart';
import '../../features/fitness/data/repository/fake_fitness_repository.dart';
import '../../features/fitness/data/repository/firebase_admin_fitness_repository.dart';
import '../../features/fitness/data/repository/fitness_repository.dart';
import '../../features/home_banners/data/repository/firebase_admin_promo_banners_repository.dart';
import '../../features/home_banners/data/repository/promo_banners_repository.dart';
import '../../features/loyalty/data/repository/fake_loyalty_repository.dart';
import '../../features/loyalty/data/repository/firebase_admin_loyalty_repository.dart';
import '../../features/loyalty/data/repository/loyalty_repository.dart';
import '../../features/orders/data/repository/firebase_admin_orders_repository.dart';
import '../../features/orders/data/repository/orders_repository.dart';
import '../../features/presets/data/repository/fake_presets_repository.dart';
import '../../features/presets/data/repository/firebase_admin_presets_repository.dart';
import '../../features/presets/data/repository/presets_repository.dart';
import '../../features/products/data/repository/firebase_admin_products_repository.dart';
import '../../features/products/data/repository/products_repository.dart';
import '../../features/review/data/repository/firebase_reviews_repository.dart';
import '../../features/review/data/repository/reviews_repository.dart';
import '../../features/suggestions/data/repository/firebase_admin_suggestions_repository.dart';
import '../../features/suggestions/data/repository/suggestions_repository.dart';
import '../../features/suppliers/data/repository/firebase_admin_suppliers_repository.dart';
import '../../features/suppliers/data/repository/suppliers_repository.dart';
import '../../features/support/data/repository/firebase_admin_support_repository.dart';
import '../../features/support/data/repository/support_repository.dart';

final getIt = GetIt.instance;

void setupInjector() {
  // نقطة وصول واحدة للـ Firestore
  final db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'default',
  );
  final auth = FirebaseAuth.instance;

  // ===== Auth =====
  getIt.registerLazySingleton<AuthRepository>(
        () => FirebaseAdminAuthRepository(auth),
  );

  // ===== Customer messages (used by orders, suggestions, support) =====
  getIt.registerLazySingleton(() => CustomerMessages(db));
  getIt.registerLazySingleton(() => BroadcastsRepository(db));

  // ===== Products =====
  getIt.registerLazySingleton<ProductsRepository>(
        () => FirebaseAdminProductsRepository(db),
  );

  // ===== Categories =====
  getIt.registerLazySingleton<CategoriesRepository>(
        () => FirebaseAdminCategoriesRepository(db),
  );

  // ===== Shipping =====
  getIt.registerLazySingleton(() => ShippingRepository(db));
  getIt.registerLazySingleton(() => PaymentSettingsRepository(db));

  // ===== Orders =====
  getIt.registerLazySingleton<OrdersRepository>(
        () => FirebaseAdminOrdersRepository(db, getIt<CustomerMessages>()),
  );

  // ===== Deals =====
  getIt.registerLazySingleton<DealsAdminRepository>(
        () => FirebaseAdminDealsRepository(db),
  );

  // ===== Suppliers =====
  getIt.registerLazySingleton<SuppliersRepository>(
        () => FirebaseAdminSuppliersRepository(db),
  );

  // ===== Suggestions =====
  getIt.registerLazySingleton<SuggestionsRepository>(
        () => FirebaseAdminSuggestionsRepository(db, getIt<CustomerMessages>()),
  );

  // ===== Support =====
  getIt.registerLazySingleton<SupportRepository>(
        () => FirebaseAdminSupportRepository(db, getIt<CustomerMessages>()),
  );

  // ===== Promo Banners =====
  getIt.registerLazySingleton<PromoBannersRepository>(
        () => FirebaseAdminPromoBannersRepository(db),
  );

  // ===== Fake (لسا ما فيهم Firestore collections) =====
  getIt.registerLazySingleton<FitnessRepository>(() => FirebaseAdminFitnessRepository(db));
  getIt.registerLazySingleton<LoyaltyRepository>(() => FirebaseAdminLoyaltyRepository(db));
  getIt.registerLazySingleton<PresetsRepository>(() => FirebaseAdminPresetsRepository(db));
  // ===== Analytics (يعتمد على باقي الـ repositories) =====
  getIt.registerLazySingleton<AnalyticsRepository>(
        () => FirebaseAnalyticsRepository(
      db,
      getIt<LoyaltyRepository>(),
      getIt<OrdersRepository>(),
      getIt<SupportRepository>(),
      getIt<SuggestionsRepository>(),
      getIt<ProductsRepository>(),
      getIt<FitnessRepository>(),
      getIt<SuppliersRepository>(),
    ),
  );
  getIt.registerLazySingleton<ReviewsRepository>(
        () => FirebaseReviewsRepository(db),
  );
}