import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../../../core/widgets/admin_side_panel.dart';
import '../../../../core/widgets/admin_status_chip.dart';
import '../../data/repository/orders_repository.dart';
import '../../domain/entities/order.dart';
import '../cubits/orders_cubit.dart';
import '../cubits/orders_state.dart';
import '../widgets/batch_details_panel.dart';
import '../widgets/order_details_panel.dart';
import '../widgets/order_filters.dart';
import '../widgets/order_status_x.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';

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
  bool _showBatches = false;
  final Set<String> _selectedOrderIds = {};

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

  void _toggleSelection(String orderId) {
    setState(() {
      if (_selectedOrderIds.contains(orderId)) {
        _selectedOrderIds.remove(orderId);
      } else {
        _selectedOrderIds.add(orderId);
      }
    });
  }

  void _openCreateBatchDialog(BuildContext context, OrdersCubit cubit) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AdminColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AdminConstants.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${_selectedOrderIds.length} ${AdminStrings.selectedOrdersCount}',
                style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary),
              ),
              const SizedBox(height: AdminConstants.spacingSm),
              AdminField(
                label: AdminStrings.batchName,
                isRequired: true,
                child: AdminTextInput(controller: nameController, hint: AdminStrings.batchNameHint),
              ),
              const SizedBox(height: AdminConstants.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: AdminButton(
                      label: AdminStrings.createBatch,
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        cubit.createBatch(name, _selectedOrderIds.toList());
                        setState(() => _selectedOrderIds.clear());
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: AdminConstants.spacingSm),
                  Expanded(
                    child: AdminButton(
                      label: AdminStrings.cancel,
                      kind: AdminButtonKind.secondary,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,###', 'ar');
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminOptionChips<bool>(
          options: const [false, true],
          selected: _showBatches,
          labelOf: (v) => v ? AdminStrings.batchesTab : AdminStrings.ordersTab,
          allowNone: false,
          onChanged: (v) => setState(() => _showBatches = v ?? _showBatches),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        if (!_showBatches) ...[
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
        ],
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

            final cubit = context.read<OrdersCubit>();

            if (_showBatches) {
              final batches = state.batches;
              return AdminDataTable(
                emptyMessage: AdminStrings.noData,
                rowCount: batches.length,
                columns: const [
                  AdminColumn(AdminStrings.batchName, flex: 3),
                  AdminColumn(AdminStrings.batchOrdersCount, flex: 1),
                  AdminColumn(AdminStrings.batchTotal, flex: 2),
                ],
                cellsBuilder: (index) {
                  final batch = batches[index];
                  final ordersInBatch =
                  state.orders.where((o) => batch.orderIds.contains(o.id)).toList();
                  final total = ordersInBatch.fold<double>(0, (s, o) => s + o.totalPrice);
                  return [
                    Text(batch.name, style: AdminTextStyles.caption),
                    Text('${ordersInBatch.length}', style: AdminTextStyles.caption),
                    Text('${currency.format(total)} ل.س', style: AdminTextStyles.caption),
                  ];
                },
                onRowTap: (index) {
                  final batch = batches[index];
                  final ordersInBatch =
                  state.orders.where((o) => batch.orderIds.contains(o.id)).toList();
                  showAdminSidePanel(
                    context,
                    title: batch.name,
                    child: BlocProvider.value(
                      value: cubit,
                      child: BatchDetailsPanel(
                        batch: batch,
                        ordersInBatch: ordersInBatch,
                        cubit: cubit,
                      ),
                    ),
                  );
                },
              );
            }

            final orders = _filterAndSort(state.orders);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_selectedOrderIds.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        '${_selectedOrderIds.length} ${AdminStrings.selectedOrdersCount}',
                        style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary),
                      ),
                      const Spacer(),
                      AdminButton(
                        label: AdminStrings.createBatch,
                        icon: Icons.playlist_add,
                        onPressed: () => _openCreateBatchDialog(context, cubit),
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminConstants.spacingMd),
                ],
                AdminDataTable(
                  emptyMessage: AdminStrings.noData,
                  rowCount: orders.length,
                  columns: const [
                    AdminColumn('', flex: 1),
                    AdminColumn(AdminStrings.orderNumber, flex: 2),
                    AdminColumn(AdminStrings.customer, flex: 2),
                    AdminColumn(AdminStrings.orderDate, flex: 2),
                    AdminColumn(AdminStrings.orderTotal, flex: 1),
                    AdminColumn(AdminStrings.orderStatus, flex: 2),
                  ],
                  cellsBuilder: (index) {
                    final order = orders[index];
                    return [
                      Checkbox(
                        value: _selectedOrderIds.contains(order.id),
                        activeColor: AdminColors.gold,
                        onChanged: (_) => _toggleSelection(order.id),
                      ),
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
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}