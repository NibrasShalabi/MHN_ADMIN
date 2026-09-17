// import 'package:bloc_test/bloc_test.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// import 'package:mhn_admin/features/deals/data/repositories/deals_admin_repository.dart';
// import 'package:mhn_admin/features/deals/domain/entities/deal_promotion.dart';
// import 'package:mhn_admin/features/deals/presentation/cubits/deals_admin_cubit.dart';
// import 'package:mhn_admin/features/deals/presentation/cubits/deals_admin_state.dart';
//
// class _FakeRepo implements DealsAdminRepository {
//   final List<DealPromotion> _promotions;
//   final bool _shouldThrow;
//
//   _FakeRepo({List<DealPromotion>? promotions, bool shouldThrow = false})
//       : _promotions = promotions ?? [],
//         _shouldThrow = shouldThrow;
//
//   @override
//   Future<List<DealPromotion>> getPromotions() async {
//     if (_shouldThrow) throw Exception('error');
//     return List.unmodifiable(_promotions);
//   }
//
//   @override
//   Future<void> addPromotion(DealPromotion promotion) async {
//     _promotions.add(promotion);
//   }
//
//   @override
//   Future<void> cancelPromotion(String id) async {
//     final i = _promotions.indexWhere((p) => p.id == id);
//     if (i != -1) _promotions[i] = _promotions[i].copyWith(isActive: false);
//   }
// }
//
// DealPromotion _promo(String id, {bool active = true, bool expired = false}) => DealPromotion(
//   id: id,
//   productId: 'P-$id',
//   productName: 'منتج $id',
//   originalPrice: 100,
//   discountPercentage: 50,
//   startTime: DateTime.now().subtract(const Duration(hours: 1)),
//   endTime: expired
//       ? DateTime.now().subtract(const Duration(minutes: 1))
//       : DateTime.now().add(const Duration(hours: 23)),
//   isActive: active,
// );
//
// void main() {
//   group('load()', () {
//     blocTest<DealsAdminCubit, DealsAdminState>(
//       'A.1 — success: promotions تظهر',
//       build: () => DealsAdminCubit(_FakeRepo(promotions: [_promo('1')])),
//       act: (c) => c.load(),
//       expect: () => [
//         const DealsAdminState(status: DealsAdminStatus.loading),
//         isA<DealsAdminState>()
//             .having((s) => s.status, 'status', DealsAdminStatus.success)
//             .having((s) => s.promotions.length, 'count', 1),
//       ],
//     );
//
//     blocTest<DealsAdminCubit, DealsAdminState>(
//       'A.2 — failure: status = failure',
//       build: () => DealsAdminCubit(_FakeRepo(shouldThrow: true)),
//       act: (c) => c.load(),
//       expect: () => [
//         const DealsAdminState(status: DealsAdminStatus.loading),
//         isA<DealsAdminState>()
//             .having((s) => s.status, 'status', DealsAdminStatus.failure)
//             .having((s) => s.error, 'error', isNotNull),
//       ],
//     );
//   });
//
//   group('DealsAdminState getters', () {
//     test('A.3 — active: فقط النشطة وغير المنتهية', () {
//       final state = DealsAdminState(
//         status: DealsAdminStatus.success,
//         promotions: [
//           _promo('1'),                          // نشط
//           _promo('2', active: false),           // ملغي
//           _promo('3', expired: true),           // منتهي الوقت
//         ],
//       );
//       expect(state.active.length, 1);
//       expect(state.active.first.id, '1');
//     });
//
//     test('A.4 — expired: الملغية والمنتهية', () {
//       final state = DealsAdminState(
//         status: DealsAdminStatus.success,
//         promotions: [
//           _promo('1'),
//           _promo('2', active: false),
//           _promo('3', expired: true),
//         ],
//       );
//       expect(state.expired.length, 2);
//     });
//
//     test('A.5 — hasActivePromotion: true لما في عرض نشط', () {
//       final state = DealsAdminState(
//         status: DealsAdminStatus.success,
//         promotions: [_promo('1')],
//       );
//       expect(state.hasActivePromotion('P-1'), isTrue);
//     });
//
//     test('A.6 — hasActivePromotion: false لما ما في عرض نشط', () {
//       final state = DealsAdminState(
//         status: DealsAdminStatus.success,
//         promotions: [_promo('2', active: false)],
//       );
//       expect(state.hasActivePromotion('P-2'), isFalse);
//     });
//   });
//
//   group('addPromotion()', () {
//     test('A.7 — success: يُضاف العرض', () async {
//       final cubit = DealsAdminCubit(_FakeRepo());
//       await cubit.load();
//       final result = await cubit.addPromotion(
//         productId: 'P-new',
//         productName: 'منتج جديد',
//         originalPrice: 100,
//         discountPercentage: 30,
//         durationHours: 24,
//       );
//       expect(result, DealsAdminResult.success);
//       expect(cubit.state.promotions.any((p) => p.productId == 'P-new'), isTrue);
//     });
//
//     // ثغرة 3: منع إضافة عرض لمنتج عنده عرض نشط
//     test('A.8 — duplicate: يُرفض العرض المكرر', () async {
//       final cubit = DealsAdminCubit(_FakeRepo(promotions: [_promo('1')]));
//       await cubit.load();
//       final result = await cubit.addPromotion(
//         productId: 'P-1', // نفس المنتج
//         productName: 'منتج 1',
//         originalPrice: 100,
//         discountPercentage: 70,
//         durationHours: 24,
//       );
//       expect(result, DealsAdminResult.duplicatePromotion);
//     });
//   });
//
//   group('cancelPromotion()', () {
//     test('A.9 — cancel: العرض يصير inactive', () async {
//       final cubit = DealsAdminCubit(_FakeRepo(promotions: [_promo('1')]));
//       await cubit.load();
//       await cubit.cancelPromotion('1');
//       expect(cubit.state.active.isEmpty, isTrue);
//       expect(cubit.state.expired.length, 1);
//     });
//   });
// }