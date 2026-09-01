import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../data/repository/analytics_repository.dart';
import '../../domain/entities/analytics_data.dart';
import '../cubits/analytics_cubit.dart';
import '../cubits/analytics_state.dart';
import '../widgets/analytics_period_x.dart';
import '../widgets/stat_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnalyticsCubit(GetIt.instance<AnalyticsRepository>())..load(),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,###', 'ar');

    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        if (state.status == AnalyticsPageStatus.loading || state.status == AnalyticsPageStatus.initial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == AnalyticsPageStatus.error) {
          return Center(child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong));
        }

        final cubit = context.read<AnalyticsCubit>();
        final daily = cubit.filteredDaily;

        final totalOrders = daily.fold<int>(0, (s, d) => s + d.orders);
        final completed = daily.fold<int>(0, (s, d) => s + d.completed);
        final cancelled = daily.fold<int>(0, (s, d) => s + d.cancelled);
        final revenue = daily.fold<double>(0, (s, d) => s + d.revenue);
        final maxOrders = daily.isEmpty ? 1 : daily.map((d) => d.orders).reduce((a, b) => a > b ? a : b);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminOptionChips<AnalyticsPeriod>(
              options: AnalyticsPeriod.values,
              selected: state.period,
              allowNone: false,
              labelOf: (p) => p.label,
              onChanged: (p) => cubit.setPeriod(p!),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth <= 700;
                final cards = [
                  StatCard(label: AdminStrings.totalOrders, value: '$totalOrders'),
                  StatCard(label: AdminStrings.completedOrders, value: '$completed', valueColor: AdminColors.gold),
                  StatCard(label: AdminStrings.cancelledOrders, value: '$cancelled', valueColor: AdminColors.danger),
                  StatCard(label: AdminStrings.totalUsers, value: '${state.data.totalUsers}'),
                  StatCard(label: AdminStrings.revenue, value: '${currency.format(revenue)} ل.س'),
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
              title: AdminStrings.ordersOverTime,
              child: SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: daily
                      .map((d) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        height: 120 * (d.orders / maxOrders),
                        decoration: BoxDecoration(
                          color: AdminColors.gold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminCard(
              title: AdminStrings.orderStatusDistribution,
              child: Column(
                children: [
                  _StatusBar(label: AdminStrings.completedOrders, value: completed, total: totalOrders, color: AdminColors.gold),
                  const SizedBox(height: AdminConstants.spacingSm),
                  _StatusBar(label: AdminStrings.cancelledOrders, value: cancelled, total: totalOrders, color: AdminColors.danger),
                ],
              ),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            LayoutBuilder(
              builder: (context, constraints) {
                final topCategories = _RankedTable(title: AdminStrings.topCategories, entries: state.data.topCategories, unit: AdminStrings.viewsWord);
                final topProducts = _RankedTable(title: AdminStrings.topProducts, entries: state.data.topProducts, unit: AdminStrings.orders);

                if (constraints.maxWidth <= 900) {
                  return Column(children: [topCategories, const SizedBox(height: AdminConstants.spacingLg), topProducts]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: topCategories),
                    const SizedBox(width: AdminConstants.spacingLg),
                    Expanded(child: topProducts),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _StatusBar({required this.label, required this.value, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AdminTextStyles.caption),
            Text('$value', style: AdminTextStyles.caption),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingXs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AdminColors.canvas,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _RankedTable extends StatelessWidget {
  final String title;
  final List<RankedEntry> entries;
  final String unit;

  const _RankedTable({required this.title, required this.entries, required this.unit});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: title,
      child: AdminDataTable(
        emptyMessage: AdminStrings.noData,
        rowCount: entries.length,
        columns: [
          const AdminColumn('', flex: 3),
          AdminColumn(unit, flex: 1),
        ],
        cellsBuilder: (index) {
          final entry = entries[index];
          return [
            Text(entry.name, style: AdminTextStyles.caption),
            Text('${entry.value}', style: AdminTextStyles.caption),
          ];
        },
      ),
    );
  }
}