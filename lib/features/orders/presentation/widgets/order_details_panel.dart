import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_status_chip.dart';
import '../../domain/entities/order.dart';
import '../cubits/orders_cubit.dart';
import 'order_status_x.dart';

class OrderDetailsPanel extends StatefulWidget {
  final Order order;
  final OrdersCubit cubit;

  const OrderDetailsPanel({super.key, required this.order, required this.cubit});

  @override
  State<OrderDetailsPanel> createState() => _OrderDetailsPanelState();
}

class _OrderDetailsPanelState extends State<OrderDetailsPanel> {
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
      widget.cubit.updateStatus(widget.order.id, status);
      Navigator.of(context).pop();
    }
  }

  void _confirmPendingStatus() {
    widget.cubit.updateStatus(
      widget.order.id,
      _pendingStatus!,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      notifyCustomer: _notifyCustomer,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final currency = NumberFormat('#,###', 'ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(order.id, style: AdminTextStyles.sectionTitle),
            const SizedBox(width: AdminConstants.spacingSm),
            AdminStatusChip(label: order.status.label, color: order.status.color),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        _InfoRow(label: AdminStrings.customer, value: order.customerName),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AdminStrings.customerPhone,
                  style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(order.customerPhone, style: AdminTextStyles.caption),
                  const SizedBox(width: AdminConstants.spacingSm),
                  InkWell(
                    onTap: () => Clipboard.setData(ClipboardData(text: order.customerPhone)),
                    child: const Icon(Icons.copy, size: 14, color: AdminColors.gold),
                  ),
                ],
              ),
            ],
          ),
        ),
        _InfoRow(label: AdminStrings.orderDate, value: dateFormat.format(order.orderDate)),
        _InfoRow(
          label: AdminStrings.payment,
          value: switch (order.paymentMethod) {
            PaymentMethod.cashOnDelivery => AdminStrings.paymentCash,
            PaymentMethod.bankTransfer => AdminStrings.paymentBank,
            null => AdminStrings.paymentNotSet,
          },
        ),
        _InfoRow(label: AdminStrings.address, value: order.address),
        if (order.statusNote != null && order.statusNote!.isNotEmpty)
          _InfoRow(label: AdminStrings.statusNote, value: order.statusNote!),
        const SizedBox(height: AdminConstants.spacingLg),
        const Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: AdminConstants.spacingLg),
        Text(AdminStrings.orderItems, style: AdminTextStyles.tableHeader),
        const SizedBox(height: AdminConstants.spacingSm),
        ...order.items.map(
              (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.productName, style: AdminTextStyles.caption),
                Text('x${item.quantity}', style: AdminTextStyles.caption),
              ],
            ),
          ),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        const Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: AdminConstants.spacingLg),
        if (order.deliveryFee > 0)
          _InfoRow(
            label: AdminStrings.deliveryFee,
            value: '${currency.format(order.deliveryFee)} ل.س',
          ),
        _InfoRow(
          label: AdminStrings.orderTotal,
          value: '${currency.format(order.totalPrice)} ل.س',
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        const Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: AdminConstants.spacingLg),
        Text(AdminStrings.changeStatus, style: AdminTextStyles.tableHeader),
        const SizedBox(height: AdminConstants.spacingSm),
        Wrap(
          spacing: AdminConstants.spacingSm,
          runSpacing: AdminConstants.spacingSm,
          children: OrderStatus.values.map((status) {
            final isCurrent = status == order.status;
            return AdminButton(
              label: status.label,
              kind: isCurrent ? AdminButtonKind.primary : AdminButtonKind.secondary,
              onPressed: isCurrent ? null : () => _selectStatus(status),
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
            decoration: const InputDecoration(
              hintText: AdminStrings.statusNote,
            ),
          ),
          const SizedBox(height: AdminConstants.spacingSm),
          Row(
            children: [
              Expanded(
                child: AdminButton(
                  label: AdminStrings.confirm,
                  onPressed: _confirmPendingStatus,
                ),
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
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary)),
          Text(value, style: AdminTextStyles.caption),
        ],
      ),
    );
  }
}