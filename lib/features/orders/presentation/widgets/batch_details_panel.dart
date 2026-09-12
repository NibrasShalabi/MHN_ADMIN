import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_stat_box.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_batch.dart';
import '../cubits/orders_cubit.dart';
import 'order_status_x.dart';

class BatchDetailsPanel extends StatefulWidget {
  final OrderBatch batch;
  final List<Order> ordersInBatch;
  final OrdersCubit cubit;

  const BatchDetailsPanel({
    super.key,
    required this.batch,
    required this.ordersInBatch,
    required this.cubit,
  });

  @override
  State<BatchDetailsPanel> createState() => _BatchDetailsPanelState();
}

class _BatchDetailsPanelState extends State<BatchDetailsPanel> {
  OrderStatus? _pendingStatus;
  final _noteController = TextEditingController();
  bool _notifyCustomer = true;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _selectStatus(OrderStatus status) {
    final needsNote = status == OrderStatus.delayed || status == OrderStatus.cancelled;
    if (needsNote) {
      setState(() => _pendingStatus = status);
    } else {
      widget.cubit.applyBulkStatus(widget.batch, status);
      Navigator.of(context).pop();
    }
  }

  void _confirmPendingStatus() {
    widget.cubit.applyBulkStatus(
      widget.batch,
      _pendingStatus!,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      notifyCustomer: _notifyCustomer,
    );
    Navigator.of(context).pop();
  }

  void _confirmUngroup() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AdminColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AdminConstants.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AdminStrings.ungroupBatchConfirm, style: AdminTextStyles.body),
              const SizedBox(height: AdminConstants.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: AdminButton(
                      label: AdminStrings.ungroupBatch,
                      kind: AdminButtonKind.danger,
                      onPressed: () {
                        widget.cubit.deleteBatch(widget.batch.id);
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
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
    final orders = widget.ordersInBatch;
    final total = orders.fold<double>(0, (s, o) => s + o.totalPrice);
    final customerCount = orders.map((o) => o.customerPhone).toSet().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.batch.name, style: AdminTextStyles.sectionTitle),
        const SizedBox(height: AdminConstants.spacingLg),
        Row(
          children: [
            Expanded(
              child: AdminStatBox(label: AdminStrings.batchOrdersCount, value: '${orders.length}'),
            ),
            const SizedBox(width: AdminConstants.spacingSm),
            Expanded(
              child: AdminStatBox(label: AdminStrings.batchCustomersCount, value: '$customerCount'),
            ),
            const SizedBox(width: AdminConstants.spacingSm),
            Expanded(
              child: AdminStatBox(
                label: AdminStrings.batchTotal,
                value: '${currency.format(total)} ل.س',
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        const Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: AdminConstants.spacingLg),
        Text(AdminStrings.orders, style: AdminTextStyles.tableHeader),
        const SizedBox(height: AdminConstants.spacingSm),
        ...orders.map(
              (o) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${o.id} — ${o.customerName}', style: AdminTextStyles.caption),
                Text(o.status.label, style: AdminTextStyles.caption.copyWith(color: o.status.color)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        const Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: AdminConstants.spacingLg),
        Text(AdminStrings.applyToAll, style: AdminTextStyles.tableHeader),
        const SizedBox(height: AdminConstants.spacingSm),
        Wrap(
          spacing: AdminConstants.spacingSm,
          runSpacing: AdminConstants.spacingSm,
          children: OrderStatus.values.map((status) {
            return AdminButton(
              label: status.label,
              kind: AdminButtonKind.secondary,
              onPressed: () => _selectStatus(status),
            );
          }).toList(),
        ),
        if (_pendingStatus != null) ...[
          const SizedBox(height: AdminConstants.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AdminStrings.messageCustomer, style: AdminTextStyles.label),
              Switch(
                value: _notifyCustomer,
                activeColor: AdminColors.gold,
                onChanged: (v) => setState(() => _notifyCustomer = v),
              ),
            ],
          ),
          const SizedBox(height: AdminConstants.spacingSm),
          TextField(
            controller: _noteController,
            maxLines: 2,
            style: AdminTextStyles.body,
            decoration: const InputDecoration(hintText: AdminStrings.statusNote),
          ),
          const SizedBox(height: AdminConstants.spacingSm),
          Row(
            children: [
              Expanded(
                child: AdminButton(label: AdminStrings.confirm, onPressed: _confirmPendingStatus),
              ),
              const SizedBox(width: AdminConstants.spacingSm),
              Expanded(
                child: AdminButton(
                  label: AdminStrings.cancel,
                  kind: AdminButtonKind.secondary,
                  onPressed: () => setState(() => _pendingStatus = null),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AdminConstants.spacingLg),
        const Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminButton(
          label: AdminStrings.ungroupBatch,
          kind: AdminButtonKind.danger,
          onPressed: _confirmUngroup,
        ),
      ],
    );
  }
}