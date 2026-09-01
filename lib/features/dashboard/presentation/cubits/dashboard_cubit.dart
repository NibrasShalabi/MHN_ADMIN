import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/data/repository/analytics_repository.dart';
import '../../../fitness/data/repository/fitness_repository.dart';
import '../../../orders/data/repository/orders_repository.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../products/data/repository/products_repository.dart';
import '../../../suggestions/data/repository/suggestions_repository.dart';
import '../../../suggestions/domain/entities/product_suggestion.dart';
import '../../../support/data/repository/support_repository.dart';
import '../../../support/domain/entities/support_message.dart';
import '../../domain/entities/dashboard_summary.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final OrdersRepository _ordersRepository;
  final SuggestionsRepository _suggestionsRepository;
  final SupportRepository _supportRepository;
  final ProductsRepository _productsRepository;
  final FitnessRepository _fitnessRepository;
  final AnalyticsRepository _analyticsRepository;

  DashboardCubit({
    required OrdersRepository ordersRepository,
    required SuggestionsRepository suggestionsRepository,
    required SupportRepository supportRepository,
    required ProductsRepository productsRepository,
    required FitnessRepository fitnessRepository,
    required AnalyticsRepository analyticsRepository,
  })  : _ordersRepository = ordersRepository,
        _suggestionsRepository = suggestionsRepository,
        _supportRepository = supportRepository,
        _productsRepository = productsRepository,
        _fitnessRepository = fitnessRepository,
        _analyticsRepository = analyticsRepository,
        super(const DashboardState());

  Future<void> load() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final orders = await _ordersRepository.getOrders();
      final suggestions = await _suggestionsRepository.getSuggestions();
      final support = await _supportRepository.getMessages();
      final products = await _productsRepository.getProducts();
      final submissions = await _fitnessRepository.getSubmissions();
      final analytics = await _analyticsRepository.getAnalytics();

      final now = DateTime.now();
      bool isToday(DateTime d) => d.year == now.year && d.month == now.month && d.day == now.day;

      final todayOrders = orders.where((o) => isToday(o.orderDate)).toList();
      final sortedOrders = [...orders]..sort((a, b) => b.orderDate.compareTo(a.orderDate));

      final summary = DashboardSummary(
        pendingOrders: orders.where((o) => o.status == OrderStatus.pending).length,
        unreviewedSuggestions: suggestions.where((s) => s.status == SuggestionStatus.underReview).length,
        openSupportMessages: support.where((m) => m.status == SupportStatus.open).length,
        outOfStockProducts: products.where((p) => p.stock == 0).length,
        fitnessSubmissions: submissions.length,
        todayOrders: todayOrders.length,
        todayRevenue: todayOrders.fold(0, (sum, o) => sum + o.totalPrice),
        completedOrdersToday: todayOrders.where((o) => o.status == OrderStatus.delivered).length,
        approxUsers: analytics.totalUsers,
        recentOrders: sortedOrders.take(5).toList(),
      );

      emit(state.copyWith(status: DashboardStatus.loaded, summary: summary));
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.error, errorMessage: e.toString()));
    }
  }
}