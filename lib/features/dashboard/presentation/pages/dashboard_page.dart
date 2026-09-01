import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../../../core/widgets/admin_status_chip.dart';
import '../../../analytics/data/repository/analytics_repository.dart';
import '../../../fitness/data/repository/fitness_repository.dart';
import '../../../orders/data/repository/orders_repository.dart';
import '../../../orders/presentation/widgets/order_status_x.dart';
import '../../../products/data/repository/products_repository.dart';
import '../../../suggestions/data/repository/suggestions_repository.dart';
import '../../../support/data/repository/support_repository.dart';
import '../../domain/entities/admin_section.dart';
import '../cubits/dashboard_cubit.dart';
import '../cubits/dashboard_state.dart';
import '../widgets/attention_card.dart';
import '../../../analytics/presentation/widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  final ValueChanged<AdminSection> onNavigate;

  const DashboardPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(
        ordersRepository: GetIt.instance<OrdersRepository>(),
        suggestionsRepository: GetIt.instance<SuggestionsRepository>(),
        supportRepository: GetIt.instance<SupportRepository>(),
        productsRepository: GetIt.instance<ProductsRepository>(),
        fitnessRepository: GetIt.instance<FitnessRepository>(),
        analyticsRepository: GetIt.instance<AnalyticsRepository>(),
      )..load(),
      child: _DashboardView(onNavigate: onNavigate),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final ValueChanged<AdminSection> onNavigate;

  const _DashboardView({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,###', 'ar');
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.status == DashboardStatus.loading || state.status == DashboardStatus.initial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == DashboardStatus.error) {
          return Center(child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong));
        }

        final s = state.summary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AdminStrings.needsAttention, style: AdminTextStyles.tableHeader),
            const SizedBox(height: AdminConstants.spacingSm),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth <= 700;
                final cards = [
                  AttentionCard(
                    label: AdminStrings.pendingOrdersCard,
                    count: s.pendingOrders,
                    onTap: () => onNavigate(AdminSection.orders),
                  ),
                  AttentionCard(
                    label: AdminStrings.unreviewedSuggestions,
                    count: s.unreviewedSuggestions,
                    onTap: () => onNavigate(AdminSection.suggestions),
                  ),
                  AttentionCard(
                    label: AdminStrings.openSupportMessages,
                    count: s.openSupportMessages,
                    onTap: () => onNavigate(AdminSection.support),
                  ),
                  AttentionCard(
                    label: AdminStrings.outOfStockProducts,
                    count: s.outOfStockProducts,
                    onTap: () => onNavigate(AdminSection.products),
                  ),
                  AttentionCard(
                    label: AdminStrings.fitnessSubmissionsCard,
                    count: s.fitnessSubmissions,
                    onTap: () => onNavigate(AdminSection.fitness),
                  ),
                ];
                return Wrap(
                  spacing: AdminConstants.spacingMd,
                  runSpacing: AdminConstants.spacingMd,
                  children: cards
                      .map((c) => SizedBox(width: isCompact ? double.infinity : 220, child: c))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth <= 700;
                final cards = [
                  StatCard(label: AdminStrings.todayOrders, value: '${s.todayOrders}'),
                  StatCard(label: AdminStrings.todayRevenue, value: '${currency.format(s.todayRevenue)} ل.س'),
                  StatCard(label: AdminStrings.approxUsers, value: '${s.approxUsers}'),
                  StatCard(label: AdminStrings.completedOrders, value: '${s.completedOrdersToday}'),
                ];
                return Wrap(
                  spacing: AdminConstants.spacingMd,
                  runSpacing: AdminConstants.spacingMd,
                  children: cards
                      .map((c) => SizedBox(width: isCompact ? double.infinity : 200, child: c))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminCard(
              title: AdminStrings.recentOrders,
              actions: [
                AdminTextAction(
                  label: AdminStrings.viewAll,
                  onTap: () => onNavigate(AdminSection.orders),
                ),
              ],
              child: AdminDataTable(
                emptyMessage: AdminStrings.noData,
                rowCount: s.recentOrders.length,
                columns: const [
                  AdminColumn(AdminStrings.orderNumber, flex: 2),
                  AdminColumn(AdminStrings.customer, flex: 2),
                  AdminColumn(AdminStrings.orderDate, flex: 2),
                  AdminColumn(AdminStrings.orderStatus, flex: 2),
                ],
                cellsBuilder: (index) {
                  final order = s.recentOrders[index];
                  return [
                    Text(order.id, style: AdminTextStyles.caption),
                    Text(order.customerName, style: AdminTextStyles.caption),
                    Text(dateFormat.format(order.orderDate), style: AdminTextStyles.caption),
                    AdminStatusChip(label: order.status.label, color: order.status.color),
                  ];
                },
                onRowTap: (_) => onNavigate(AdminSection.orders),
              ),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminCard(
              title: AdminStrings.quickActions,
              child: Wrap(
                spacing: AdminConstants.spacingSm,
                runSpacing: AdminConstants.spacingSm,
                children: [
                  AdminButton(
                    label: AdminStrings.addProduct,
                    icon: Icons.add,
                    kind: AdminButtonKind.secondary,
                    onPressed: () => onNavigate(AdminSection.products),
                  ),
                  AdminButton(
                    label: AdminStrings.addCategory,
                    icon: Icons.add,
                    kind: AdminButtonKind.secondary,
                    onPressed: () => onNavigate(AdminSection.categories),
                  ),
                  AdminButton(
                    label: AdminStrings.orders,
                    icon: Icons.receipt_long_outlined,
                    kind: AdminButtonKind.secondary,
                    onPressed: () => onNavigate(AdminSection.orders),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}