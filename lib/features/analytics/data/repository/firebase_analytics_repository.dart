import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
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

/// Firebase implementation لـ AnalyticsRepository
///
/// Read optimization:
/// - كل البيانات تُجلب parallel بـ Future.wait
/// - daily يُحسب من الـ orders الحقيقية (ما في fake data)
/// - totalUsers يُقرأ من config/stats (يُحدَّث بـ Cloud Function)
/// - Read count: ~7 reads per analytics load (واحد per repository)
class FirebaseAnalyticsRepository implements AnalyticsRepository {
  final FirebaseFirestore _db;
  final LoyaltyRepository _loyaltyRepository;
  final OrdersRepository _ordersRepository;
  final SupportRepository _supportRepository;
  final SuggestionsRepository _suggestionsRepository;
  final ProductsRepository _productsRepository;
  final FitnessRepository _fitnessRepository;
  final SuppliersRepository _suppliersRepository;

  FirebaseAnalyticsRepository(
      this._db,
      this._loyaltyRepository,
      this._ordersRepository,
      this._supportRepository,
      this._suggestionsRepository,
      this._productsRepository,
      this._fitnessRepository,
      this._suppliersRepository,
      );

  List<RankedEntry> _rank(Map<String, num> totals, {int take = 5}) {
    return (totals.entries
        .map((e) => RankedEntry(name: e.key, value: e.value))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value)))
        .take(take)
        .toList();
  }

  @override
  Future<AnalyticsData> getAnalytics() async {
    // جلب كل البيانات parallel — تقليل الـ latency
    final results = await Future.wait([
      _ordersRepository.getOrders(),
      _supportRepository.getMessages(),
      _suggestionsRepository.getSuggestions(),
      _productsRepository.getProducts(),
      _suppliersRepository.getSuppliers(),
      _loyaltyRepository.getTransactions(),
      _fitnessRepository.getSubmissions(),
      _db.collection('config').doc('stats').get(), // totalUsers
    ]);

    final orders = results[0] as List<Order>;
    final support = results[1] as List;
    final suggestions = results[2] as List;
    final products = results[3] as List;
    final suppliers = results[4] as List;
    final loyaltyTxs = results[5] as List;
    final submissions = results[6] as List;
    final statsDoc = results[7] as DocumentSnapshot<Map<String, dynamic>>;

    final totalUsers = statsDoc.data()?['totalUsers'] as int? ?? 0;

    // ===== Daily (من الـ orders الحقيقية) =====
    final daily = _buildDaily(orders);

    // ===== Financial =====
    final totalRevenue = orders.fold<double>(0, (s, o) => s + (o as Order).totalPrice);
    final margins = (products as List).where((p) => p.costPrice != null && p.price > 0)
        .map((p) => (p.price - p.costPrice!) / p.price).toList();
    final avgMargin = margins.isEmpty ? 0.0 : margins.reduce((a, b) => a + b) / margins.length;
    final averageOrderValue = orders.isEmpty ? 0.0 : totalRevenue / orders.length;

    // ===== Customers =====
    final orderCounts = <String, num>{};
    final orderSpend = <String, num>{};
    final productOrderCounts = <String, num>{};

    for (final o in orders) {
      final key = o.customerName;
      orderCounts.update(key, (v) => v + 1, ifAbsent: () => 1);
      orderSpend.update(key, (v) => v + o.totalPrice, ifAbsent: () => o.totalPrice);
      for (final item in o.items) {
        productOrderCounts.update(item.productName, (v) => v + item.quantity, ifAbsent: () => item.quantity);
      }
    }

    final complaintCounts = <String, num>{};
    final activity = <String, num>{};
    for (final m in (support as List)) {
      if (m.topic == SupportTopic.complaint) {
        complaintCounts.update(m.sentBy, (v) => v + 1, ifAbsent: () => 1);
      }
      activity.update(m.sentBy, (v) => v + 1, ifAbsent: () => 1);
    }
    for (final s in (suggestions as List)) {
      activity.update(s.suggestedBy, (v) => v + 1, ifAbsent: () => 1);
    }
    for (final e in orderCounts.entries) {
      activity.update(e.key, (v) => v + e.value, ifAbsent: () => e.value);
    }

    // ===== Suppliers =====
    final supplierNameById = {for (final s in (suppliers as List)) s.id: s.name};
    final supplierIdByProductName = {
      for (final p in (products as List))
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

    // ===== Fitness =====
    final programCounts = <String, num>{};
    for (final s in (submissions as List)) {
      programCounts.update(s.programTitle, (v) => v + 1, ifAbsent: () => 1);
    }

    // ===== Loyalty =====
    final loyaltyTotals = <String, int>{};
    final loyaltyNames = <String, String>{};
    for (final t in (loyaltyTxs as List)) {
      loyaltyTotals.update(t.userPhone, (v) => v + (t.points as int), ifAbsent: () => t.points as int);
      loyaltyNames[t.userPhone] = t.userName;
    }
    final loyaltyEarners = _rank(
      loyaltyTotals.map((phone, points) => MapEntry(loyaltyNames[phone] ?? phone, points)),
    );

    // ===== صور المنتجات =====
    final totalProductImages = (products as List).fold<int>(0, (s, p) => s + (p.images as List).length);

    final mostOrderedProduct = productOrderCounts.isEmpty
        ? null
        : RankedEntry(
      name: productOrderCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key,
      value: productOrderCounts.entries.reduce((a, b) => a.value > b.value ? a : b).value,
    );

    return AnalyticsData(
      daily: daily,
      topCategories: const [], // يحتاج tracking منفصل
      topProducts: _rank(productOrderCounts),
      topLoyaltyEarners: loyaltyEarners,
      totalUsers: totalUsers,
      netProfit: totalRevenue * avgMargin,
      averageOrderValue: averageOrderValue,
      topOrderingCustomers: _rank(orderCounts),
      topSpendingCustomers: _rank(orderSpend),
      topComplainingCustomers: _rank(complaintCounts),
      mostActiveCustomers: _rank(activity),
      topSellingSuppliers: _rank(supplierUnitsSold),
      topPrograms: _rank(programCounts),
      totalProductImages: totalProductImages,
      mostOrderedProduct: mostOrderedProduct,
    );
  }

  /// يحسب الـ daily من الـ orders الحقيقية — آخر 30 يوم
  List<DailyPoint> _buildDaily(List<Order> orders) {
    final now = DateTime.now();
    final days = List.generate(30, (i) => now.subtract(Duration(days: 29 - i)));

    return days.map((day) {
      final dayOrders = orders.where((o) {
        final d = o.orderDate;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).toList();

      final completed = dayOrders.where((o) => o.status == OrderStatus.delivered).length;
      final cancelled = dayOrders.where((o) => o.status == OrderStatus.cancelled).length;
      final revenue = dayOrders.fold<double>(0, (s, o) => s + o.totalPrice);

      return DailyPoint(
        date: day,
        orders: dayOrders.length,
        completed: completed,
        cancelled: cancelled,
        revenue: revenue,
        newUsers: 0, // يحتاج Firebase Auth tracking
      );
    }).toList();
  }
}