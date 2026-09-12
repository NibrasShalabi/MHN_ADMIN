import 'dart:math' as math;

import '../../../fitness/data/repository/fitness_repository.dart';
import '../../../loyalty/data/repository/loyalty_repository.dart';
import '../../../orders/data/repository/orders_repository.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../products/data/repository/products_repository.dart';
import '../../../suggestions/data/repository/suggestions_repository.dart';
import '../../../suppliers/data/repository/suppliers_repository.dart';
import '../../../support/data/repository/support_repository.dart';
import '../../../support/domain/entities/support_message.dart';
import '../../domain/entities/analytics_data.dart';
import 'analytics_repository.dart';

class FakeAnalyticsRepository implements AnalyticsRepository {
  final LoyaltyRepository _loyaltyRepository;
  final OrdersRepository _ordersRepository;
  final SupportRepository _supportRepository;
  final SuggestionsRepository _suggestionsRepository;
  final ProductsRepository _productsRepository;
  final FitnessRepository _fitnessRepository;
  final SuppliersRepository _suppliersRepository;

  FakeAnalyticsRepository(
      this._loyaltyRepository,
      this._ordersRepository,
      this._supportRepository,
      this._suggestionsRepository,
      this._productsRepository,
      this._fitnessRepository,
      this._suppliersRepository,
      );

  List<RankedEntry> _rank(Map<String, num> totals, {int take = 5}) {
    final ranked = totals.entries
        .map((e) => RankedEntry(name: e.key, value: e.value))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(take).toList();
  }

  Future<List<RankedEntry>> _topLoyaltyEarners() async {
    final transactions = await _loyaltyRepository.getTransactions();
    final totals = <String, int>{};
    final names = <String, String>{};
    for (final t in transactions) {
      totals.update(t.userPhone, (v) => v + t.points, ifAbsent: () => t.points);
      names[t.userPhone] = t.userName;
    }
    return _rank(totals.map((phone, points) => MapEntry(names[phone] ?? phone, points)));
  }

  @override
  Future<AnalyticsData> getAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    // A fixed seed keeps the demo reproducible (same numbers every run)
    // while looking like an actual order history instead of the flat
    // "i % 7" sawtooth this used to be — that repeated identically every
    // week and was the first thing that gave away it was fake.
    final random = math.Random(7);
    var level = 6.0;
    final daily = List.generate(30, (i) {
      final date = now.subtract(Duration(days: 29 - i));
      // A small random step plus a slight upward drift, clamped so it
      // can't wander into negative or implausible territory.
      level = (level + (random.nextDouble() - 0.42) * 2.4).clamp(2.0, 16.0);
      final orders = level.round();
      final cancelled = (orders * 0.12 + random.nextDouble()).floor().clamp(0, orders);
      return DailyPoint(
        date: date,
        orders: orders,
        completed: orders - cancelled,
        cancelled: cancelled,
        revenue: orders * (22000 + random.nextInt(6000)).toDouble(),
        newUsers: 1 + random.nextInt(4),
      );
    });

    final orders = await _ordersRepository.getOrders();
    final support = await _supportRepository.getMessages();
    final suggestions = await _suggestionsRepository.getSuggestions();
    final products = await _productsRepository.getProducts();

    // --- Customers: orders, spend, complaints, and an "activity" score
    // that's just those three added together. Keyed by phone where an
    // order has one; support/suggestions only carry a name, so those
    // fall back to matching by name — imprecise until they carry a
    // customer id too, but the best join available today.
    final orderCounts = <String, num>{};
    final orderSpend = <String, num>{};
    for (final o in orders) {
      final key = o.customerName;
      orderCounts.update(key, (v) => v + 1, ifAbsent: () => 1);
      orderSpend.update(key, (v) => v + o.totalPrice, ifAbsent: () => o.totalPrice);
    }

    final complaintCounts = <String, num>{};
    for (final m in support) {
      if (m.topic != SupportTopic.complaint) continue;
      complaintCounts.update(m.sentBy, (v) => v + 1, ifAbsent: () => 1);
    }

    final activity = <String, num>{};
    void addActivity(String key, num amount) =>
        activity.update(key, (v) => v + amount, ifAbsent: () => amount);
    for (final e in orderCounts.entries) addActivity(e.key, e.value);
    for (final m in support) addActivity(m.sentBy, 1);
    for (final s in suggestions) addActivity(s.suggestedBy, 1);

    // --- Financial: net profit is estimated via the average margin of
    // priced products (see the field doc on AnalyticsData) rather than
    // summed per order, since OrderItem doesn't carry a product id yet.
    final totalRevenue = orders.fold<double>(0, (s, o) => s + o.totalPrice);
    final margins = products
        .where((p) => p.costPrice != null && p.price > 0)
        .map((p) => (p.price - p.costPrice!) / p.price)
        .toList();
    final avgMargin =
    margins.isEmpty ? 0.0 : margins.reduce((a, b) => a + b) / margins.length;
    final netProfit = totalRevenue * avgMargin;
    final averageOrderValue = orders.isEmpty ? 0.0 : totalRevenue / orders.length;

    // --- Fitness: only what's honestly measurable — see the field doc.
    final submissions = await _fitnessRepository.getSubmissions();
    final programCounts = <String, num>{};
    for (final s in submissions) {
      programCounts.update(s.programTitle, (v) => v + 1, ifAbsent: () => 1);
    }

    // --- Suppliers: matched by product name → product → supplierId, since
    // OrderItem doesn't carry a product id yet (same limitation noted on
    // netProfit). Counts units sold, which is honestly computable; revenue
    // per supplier isn't, since OrderItem has no per-line price.
    final suppliers = await _suppliersRepository.getSuppliers();
    final supplierNameById = {for (final s in suppliers) s.id: s.name};
    final supplierIdByProductName = {
      for (final p in products)
        if (p.supplierId != null) p.name: p.supplierId!,
    };
    final supplierUnitsSold = <String, num>{};
    for (final o in orders) {
      for (final item in o.items) {
        final supplierId = supplierIdByProductName[item.productName];
        if (supplierId == null) continue;
        final name = supplierNameById[supplierId] ?? supplierId;
        supplierUnitsSold.update(name, (v) => v + item.quantity, ifAbsent: () => item.quantity);
      }
    }

    return AnalyticsData(
      daily: daily,
      topCategories: const [
        RankedEntry(name: 'العناية بالبشرة', value: 420),
        RankedEntry(name: 'برامج اللياقة', value: 210),
        RankedEntry(name: 'العناية بالشعر', value: 150),
      ],
      topProducts: const [
        RankedEntry(name: 'سيروم 1', value: 88),
        RankedEntry(name: 'سيروم 4', value: 61),
        RankedEntry(name: 'سيروم 2', value: 47),
      ],
      topLoyaltyEarners: await _topLoyaltyEarners(),
      totalUsers: 356,
      netProfit: netProfit,
      averageOrderValue: averageOrderValue,
      topOrderingCustomers: _rank(orderCounts),
      topSpendingCustomers: _rank(orderSpend),
      topComplainingCustomers: _rank(complaintCounts),
      mostActiveCustomers: _rank(activity),
      // Real once a supplier has at least one order — empty until then,
      // which the UI already renders as "no supplier system yet"... no,
      // this IS the supplier system; an empty result here just means no
      // supplier-tagged product has sold yet.
      topSellingSuppliers: _rank(supplierUnitsSold),
      topPrograms: _rank(programCounts),
    );
  }
}