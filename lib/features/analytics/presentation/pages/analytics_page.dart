import 'package:fl_chart/fl_chart.dart';
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
import '../../../../core/widgets/admin_legend_dot.dart';
import '../../../../core/widgets/admin_responsive_row.dart';
import '../../../../core/widgets/admin_section_header.dart';
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

  /// Percent change of [current] vs [previous]. Null when there's nothing
  /// to compare against — the stat card hides the arrow rather than
  /// showing a 0%/∞% that would mislead more than it informs.
  double? _trend(num current, List<dynamic> previousWindow, num previousSum) {
    if (previousWindow.isEmpty || previousSum == 0) return null;
    return ((current - previousSum) / previousSum) * 100;
  }

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
        final previous = cubit.previousDaily;

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
            _buildFinancialSection(state, daily, previous, currency),
            const SizedBox(height: AdminConstants.spacingLg),
            _buildChartsSection(daily),
            const SizedBox(height: AdminConstants.spacingLg),
            const AdminSectionHeader(title: AdminStrings.catalogStats),
            _buildCatalogSection(state),
            const SizedBox(height: AdminConstants.spacingLg),
            const AdminSectionHeader(title: AdminStrings.customerStats),
            _buildCustomerSection(state, currency),
            const SizedBox(height: AdminConstants.spacingLg),
            const AdminSectionHeader(title: AdminStrings.supplierStats),
            _buildSupplierSection(state),
            const SizedBox(height: AdminConstants.spacingLg),
            const AdminSectionHeader(title: AdminStrings.fitnessStats),
            _buildFitnessSection(state),
          ],
        );
      },
    );
  }

  Widget _buildFinancialSection(
      AnalyticsState state,
      List<DailyPoint> daily,
      List<DailyPoint> previous,
      NumberFormat currency,
      ) {
    final totalOrders = daily.fold<int>(0, (s, d) => s + d.orders);
    final completed = daily.fold<int>(0, (s, d) => s + d.completed);
    final cancelled = daily.fold<int>(0, (s, d) => s + d.cancelled);
    final revenue = daily.fold<double>(0, (s, d) => s + d.revenue);

    final prevOrders = previous.fold<int>(0, (s, d) => s + d.orders);
    final prevRevenue = previous.fold<double>(0, (s, d) => s + d.revenue);
    final prevCompleted = previous.fold<int>(0, (s, d) => s + d.completed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminSectionHeader(title: AdminStrings.financialStats),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth <= 700;
            final cards = [
              StatCard(
                label: AdminStrings.totalOrders,
                value: '$totalOrders',
                icon: Icons.receipt_long_outlined,
                trend: _trend(totalOrders, previous, prevOrders),
              ),
              StatCard(
                label: AdminStrings.completedOrders,
                value: '$completed',
                valueColor: AdminColors.success,
                icon: Icons.check_circle_outline,
                trend: _trend(completed, previous, prevCompleted),
              ),
              StatCard(
                label: AdminStrings.cancelledOrders,
                value: '$cancelled',
                valueColor: AdminColors.danger,
                icon: Icons.cancel_outlined,
              ),
              StatCard(
                label: AdminStrings.totalUsers,
                value: '${state.data.totalUsers}',
                icon: Icons.people_alt_outlined,
              ),
              StatCard(
                label: AdminStrings.revenue,
                value: '${currency.format(revenue)} ل.س',
                icon: Icons.payments_outlined,
                trend: _trend(revenue, previous, prevRevenue),
              ),
              StatCard(
                label: AdminStrings.netProfit,
                value: '${currency.format(state.data.netProfit)} ل.س',
                valueColor: AdminColors.gold,
                icon: Icons.trending_up,
              ),
              StatCard(
                label: AdminStrings.averageOrderValue,
                value: '${currency.format(state.data.averageOrderValue)} ل.س',
                icon: Icons.calculate_outlined,
              ),
            ];
            return Wrap(
              spacing: AdminConstants.spacingMd,
              runSpacing: AdminConstants.spacingMd,
              children: cards
                  .map((c) => SizedBox(width: isCompact ? double.infinity : 210, child: c))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChartsSection(List<DailyPoint> daily) {
    final completed = daily.fold<int>(0, (s, d) => s + d.completed);
    final cancelled = daily.fold<int>(0, (s, d) => s + d.cancelled);

    return AdminResponsiveRow(
      children: [
        AdminCard(
          title: AdminStrings.ordersOverTime,
          child: SizedBox(height: 260, child: _OrdersTrendChart(daily: daily)),
        ),
        AdminCard(
          title: AdminStrings.orderStatusDistribution,
          child: _StatusDonut(completed: completed, cancelled: cancelled),
        ),
      ],
    );
  }

  Widget _buildCatalogSection(AnalyticsState state) {
    return Column(
      children: [
        AdminResponsiveRow(
          children: [
            StatCard(
              label: AdminStrings.totalProductImages,
              value: '${state.data.totalProductImages}',
              icon: Icons.photo_library_outlined,
            ),
            StatCard(
              label: AdminStrings.mostOrderedProduct,
              value: state.data.mostOrderedProduct == null
                  ? AdminStrings.noData
                  : '${state.data.mostOrderedProduct!.name} (${state.data.mostOrderedProduct!.value} ${AdminStrings.orders})',
              icon: Icons.star_outline,
              valueColor: AdminColors.gold,
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminResponsiveRow(
          children: [
            _RankedTable(
              title: AdminStrings.topCategories,
              entries: state.data.topCategories,
              unit: AdminStrings.viewsWord,
              icon: Icons.category_outlined,
            ),
            _RankedTable(
              title: AdminStrings.topProducts,
              entries: state.data.topProducts,
              unit: AdminStrings.orders,
              icon: Icons.inventory_2_outlined,
            ),
            _RankedTable(
              title: AdminStrings.loyaltyLeaderboard,
              entries: state.data.topLoyaltyEarners,
              unit: AdminStrings.pointsBalance,
              icon: Icons.local_fire_department_outlined,
              accentColor: AdminColors.gold,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerSection(AnalyticsState state, NumberFormat currency) {
    return Column(
      children: [
        AdminResponsiveRow(
          children: [
            _RankedTable(
              title: AdminStrings.topOrderingCustomers,
              entries: state.data.topOrderingCustomers,
              unit: AdminStrings.orders,
              icon: Icons.shopping_bag_outlined,
            ),
            _RankedTable(
              title: AdminStrings.topSpendingCustomers,
              entries: state.data.topSpendingCustomers,
              unit: AdminStrings.revenue,
              icon: Icons.savings_outlined,
              accentColor: AdminColors.gold,
              formatValue: (v) => currency.format(v),
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminResponsiveRow(
          children: [
            _RankedTable(
              title: AdminStrings.topComplainingCustomers,
              entries: state.data.topComplainingCustomers,
              unit: AdminStrings.complaints,
              icon: Icons.report_gmailerrorred_outlined,
              accentColor: AdminColors.danger,
            ),
            _RankedTable(
              title: AdminStrings.mostActiveCustomers,
              entries: state.data.mostActiveCustomers,
              unit: AdminStrings.activityScore,
              icon: Icons.bolt_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupplierSection(AnalyticsState state) {
    return _RankedTable(
      title: AdminStrings.topSellingSuppliers,
      entries: state.data.topSellingSuppliers,
      unit: AdminStrings.orders,
      icon: Icons.local_shipping_outlined,
      emptyNote: AdminStrings.noData,
    );
  }

  Widget _buildFitnessSection(AnalyticsState state) {
    return _RankedTable(
      title: AdminStrings.topPrograms,
      entries: state.data.topPrograms,
      unit: AdminStrings.submissions,
      icon: Icons.fitness_center_outlined,
      emptyNote: AdminStrings.noData,
    );
  }
}

/// Smooth line + soft area fill, with real axis labels and a bordered
/// tooltip — a boardroom chart, not a sparkline. Easier to read a 30-day
/// trend from at a glance than the same data as 30 thin bars.
class _OrdersTrendChart extends StatelessWidget {
  final List<DailyPoint> daily;

  const _OrdersTrendChart({required this.daily});

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) {
      return Center(child: Text(AdminStrings.noData, style: AdminTextStyles.caption));
    }

    final maxOrders = daily.map((d) => d.orders).reduce((a, b) => a > b ? a : b).toDouble();
    final peakY = maxOrders * 1.25;
    final spots = [
      for (var i = 0; i < daily.length; i++) FlSpot(i.toDouble(), daily[i].orders.toDouble()),
    ];

    // A handful of evenly-spaced date labels — one per day would collide
    // on a 30-day range, so this skips to roughly 5-6 labels regardless
    // of the period length.
    final labelStep = (daily.length / 5).ceil().clamp(1, daily.length);
    final dateFormat = DateFormat('d/M', 'ar');

    return Padding(
      padding: const EdgeInsets.only(top: AdminConstants.spacingMd, left: AdminConstants.spacingSm),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: peakY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (peakY / 4).clamp(1, double.infinity),
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AdminColors.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (peakY / 4).clamp(1, double.infinity),
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: AdminTextStyles.caption.copyWith(color: AdminColors.textDisabled, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: labelStep.toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= daily.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: AdminConstants.spacingXs),
                    child: Text(
                      dateFormat.format(daily[index].date),
                      style: AdminTextStyles.caption
                          .copyWith(color: AdminColors.textDisabled, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            getTouchedSpotIndicator: (barData, indexes) => indexes.map((_) {
              return TouchedSpotIndicatorData(
                const FlLine(color: AdminColors.gold, strokeWidth: 1, dashArray: [3, 3]),
                FlDotData(
                  getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                    radius: 4,
                    color: AdminColors.gold,
                    strokeWidth: 2,
                    strokeColor: AdminColors.surfaceRaised,
                  ),
                ),
              );
            }).toList(),
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AdminColors.surfaceRaised,
              tooltipBorder: const BorderSide(color: AdminColors.gold, width: 1),
              tooltipRoundedRadius: AdminConstants.radiusSm,
              getTooltipItems: (spots) => spots.map((s) {
                final point = daily[s.x.toInt()];
                return LineTooltipItem(
                  '${s.y.toInt()} ${AdminStrings.orders}\n',
                  AdminTextStyles.body.copyWith(color: AdminColors.gold, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: DateFormat('d MMMM', 'ar').format(point.date),
                      style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AdminColors.gold,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AdminColors.gold.withValues(alpha: 0.28),
                    AdminColors.gold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Donut with the grand total centered in the hole and each slice
/// labeled by percentage — the standard "premium dashboard" donut, not
/// just two stacked progress bars.
class _StatusDonut extends StatelessWidget {
  final int completed;
  final int cancelled;

  const _StatusDonut({required this.completed, required this.cancelled});

  @override
  Widget build(BuildContext context) {
    final total = completed + cancelled;
    if (total == 0) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(AdminStrings.noData, style: AdminTextStyles.caption)),
      );
    }

    final completedPct = completed / total * 100;
    final cancelledPct = cancelled / total * 100;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 58,
                  startDegreeOffset: -90,
                  sections: [
                    PieChartSectionData(
                      value: completed.toDouble(),
                      color: AdminColors.success,
                      radius: 28,
                      title: completedPct >= 8 ? '${completedPct.toStringAsFixed(0)}%' : '',
                      titleStyle: AdminTextStyles.caption.copyWith(
                        color: AdminColors.surfaceRaised,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      borderSide: const BorderSide(color: AdminColors.surface, width: 2),
                    ),
                    PieChartSectionData(
                      value: cancelled.toDouble(),
                      color: AdminColors.danger,
                      radius: 28,
                      title: cancelledPct >= 8 ? '${cancelledPct.toStringAsFixed(0)}%' : '',
                      titleStyle: AdminTextStyles.caption.copyWith(
                        color: AdminColors.surfaceRaised,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      borderSide: const BorderSide(color: AdminColors.surface, width: 2),
                    ),
                  ],
                ),
              ),
              // Sits in the donut's hole — the grand total, the number
              // an owner glances at first.
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: AdminTextStyles.pageTitle.copyWith(color: AdminColors.gold),
                  ),
                  Text(
                    AdminStrings.totalOrders,
                    style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AdminConstants.spacingMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AdminLegendDot(color: AdminColors.success, label: AdminStrings.completedOrders, value: completed),
            AdminLegendDot(color: AdminColors.danger, label: AdminStrings.cancelledOrders, value: cancelled),
          ],
        ),
      ],
    );
  }
}

class _RankedTable extends StatelessWidget {
  final String title;
  final List<RankedEntry> entries;
  final String unit;
  final IconData? icon;
  final Color? accentColor;
  final String Function(num)? formatValue;
  final String? emptyNote;

  const _RankedTable({
    required this.title,
    required this.entries,
    required this.unit,
    this.icon,
    this.accentColor,
    this.formatValue,
    this.emptyNote,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: title,
      actions: icon != null
          ? [Icon(icon, size: 16, color: accentColor ?? AdminColors.textSecondary)]
          : const [],
      child: entries.isEmpty && emptyNote != null
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingMd),
        child: Text(
          emptyNote!,
          style: AdminTextStyles.caption.copyWith(color: AdminColors.textDisabled),
        ),
      )
          : AdminDataTable(
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
            Text(
              formatValue != null ? formatValue!(entry.value) : '${entry.value}',
              style: AdminTextStyles.caption.copyWith(color: accentColor),
            ),
          ];
        },
      ),
    );
  }
}