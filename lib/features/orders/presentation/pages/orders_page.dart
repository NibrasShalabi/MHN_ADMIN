import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../../../core/widgets/admin_side_panel.dart';
import '../../../../core/widgets/admin_status_chip.dart';
import '../../data/repository/orders_repository.dart';
import '../../domain/entities/order.dart';
import '../cubits/orders_cubit.dart';
import '../cubits/orders_state.dart';
import '../widgets/order_details_panel.dart';
import '../widgets/order_filters.dart';
import '../widgets/order_status_x.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit(GetIt.instance<OrdersRepository>())..loadOrders(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  OrderTab _tab = OrderTab.pending;
  SortOrder _sort = SortOrder.newest;

  List<Order> _filterAndSort(List<Order> orders) {
    final filtered = orders.where((o) {
      final isPending = o.status == OrderStatus.pending;
      return _tab == OrderTab.pending ? isPending : !isPending;
    }).toList();

    filtered.sort((a, b) => _sort == SortOrder.newest
        ? b.orderDate.compareTo(a.orderDate)
        : a.orderDate.compareTo(b.orderDate));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,###', 'ar');
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminOptionChips<OrderTab>(
          options: OrderTab.values,
          selected: _tab,
          labelOf: (t) => t.label,
          allowNone: false,
          onChanged: (t) => setState(() => _tab = t ?? _tab),
        ),
        const SizedBox(height: AdminConstants.spacingMd),
        Row(
          children: [
            Text(AdminStrings.sortBy, style: AdminTextStyles.caption),
            const SizedBox(width: AdminConstants.spacingSm),
            AdminOptionChips<SortOrder>(
              options: SortOrder.values,
              selected: _sort,
              labelOf: (s) => s.label,
              allowNone: false,
              onChanged: (s) => setState(() => _sort = s ?? _sort),
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.status == OrdersStatus.loading ||
                state.status == OrdersStatus.initial) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == OrdersStatus.error) {
              return Center(
                child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong),
              );
            }

            final orders = _filterAndSort(state.orders);
            final cubit = context.read<OrdersCubit>();

            return AdminDataTable(
              emptyMessage: AdminStrings.noData,
              rowCount: orders.length,
              columns: const [
                AdminColumn(AdminStrings.orderNumber, flex: 2),
                AdminColumn(AdminStrings.customer, flex: 2),
                AdminColumn(AdminStrings.orderDate, flex: 2),
                AdminColumn(AdminStrings.orderTotal, flex: 1),
                AdminColumn(AdminStrings.orderStatus, flex: 2),
              ],
              cellsBuilder: (index) {
                final order = orders[index];
                return [
                  Text(order.id, style: AdminTextStyles.caption),
                  Text(order.customerName, style: AdminTextStyles.caption),
                  Text(dateFormat.format(order.orderDate), style: AdminTextStyles.caption),
                  Text('${currency.format(order.totalPrice)} ل.س', style: AdminTextStyles.caption),
                  AdminStatusChip(label: order.status.label, color: order.status.color),
                ];
              },
              onRowTap: (index) {
                final order = orders[index];
                showAdminSidePanel(
                  context,
                  title: order.id,
                  child: BlocProvider.value(
                    value: cubit,
                    child: OrderDetailsPanel(order: order, cubit: cubit),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}