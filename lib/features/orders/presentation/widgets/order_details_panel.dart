import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_status_chip.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_check.dart';
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
  late PaymentStatus _paymentStatus = widget.order.paymentStatus;

  /// Re-computed once when the panel opens — a handful of reads, not per rebuild.
  late final Future<OrderCheck> _check = widget.cubit.checkOrder(widget.order);

  bool _choosingRejectReason = false;
  String? _rejectPreset;
  final _rejectNote = TextEditingController();

  void _setPayment(PaymentStatus status, {String? reason}) {
    setState(() {
      _paymentStatus = status;
      _choosingRejectReason = false;
    });
    widget.cubit.updatePaymentStatus(widget.order, status, reason: reason);
  }

  void _confirmReject() {
    final note = _rejectNote.text.trim();
    final reason = [?_rejectPreset, if (note.isNotEmpty) note].join(' — ');
    _setPayment(PaymentStatus.rejected, reason: reason.isEmpty ? null : reason);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _rejectNote.dispose();
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
        _CopyRow(label: AdminStrings.customerPhone, value: order.customerPhone),
        if (order.customerSecondaryPhone case final phone?)
          _CopyRow(label: AdminStrings.customerSecondaryPhone, value: phone),
        if (order.gender case final gender?)
          _InfoRow(label: AdminStrings.gender, value: gender == 'female' ? AdminStrings.female : AdminStrings.male),
        _InfoRow(label: AdminStrings.orderDate, value: dateFormat.format(order.orderDate)),
        _InfoRow(
          label: AdminStrings.payment,
          value: switch (order.paymentMethod) {
            PaymentMethod.cashOnDelivery => AdminStrings.paymentCash,
            PaymentMethod.bankTransfer => AdminStrings.paymentBank,
            PaymentMethod.usdtTrc20 => 'USDT · TRC20',
            PaymentMethod.usdtBep20 => 'USDT · BEP20',
            PaymentMethod.usdtErc20 => 'USDT · ERC20',
            PaymentMethod.shamCash => AdminStrings.paymentShamCash,
            PaymentMethod.loyaltyPoints => AdminStrings.paymentPoints,
            null => AdminStrings.paymentNotSet,
          },
        ),
        if (order.txid case final txid?) ...[
          _CopyRow(label: AdminStrings.txid, value: txid),
          if (_explorerUrl(order.paymentMethod, txid) case final url?)
            _LinkRow(label: '', url: url, text: AdminStrings.openInExplorer),
        ],
        if (order.receiptUrl case final url?)
          _LinkRow(label: AdminStrings.paymentReceipt, url: url),
        if (order.governorate case final g?) _InfoRow(label: AdminStrings.governorate, value: g),
        if (order.area case final a?) _InfoRow(label: AdminStrings.area, value: a),
        if (order.address.isNotEmpty) _InfoRow(label: AdminStrings.address, value: order.address),
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
        if (order.itemsTotal > 0) ...[
          _InfoRow(label: AdminStrings.itemsTotal, value: '${currency.format(order.itemsTotal)} ل.س'),
          _InfoRow(label: AdminStrings.supplyShipping, value: '${currency.format(order.supplyShipping)} ل.س'),
          _InfoRow(label: AdminStrings.deliveryFee, value: '${currency.format(order.deliveryFee)} ل.س'),
        ],
        _InfoRow(label: AdminStrings.grandTotal, value: '${currency.format(order.totalPrice)} ل.س'),
        if (order.itemsTotal > 0)
          FutureBuilder<OrderCheck>(
            future: _check,
            builder: (context, snap) => switch (snap.data) {
              null => const SizedBox.shrink(),
              final check => _CheckNote(check: check, total: order.totalPrice, currency: currency),
            },
          ),
        if (order.pointsTotal > 0)
          _InfoRow(
            label: AdminStrings.orderPointsTotal,
            value: '${currency.format(order.pointsTotal)} ${AdminStrings.pointsWord}',
          ),
        const SizedBox(height: AdminConstants.spacingLg),
        const Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: AdminConstants.spacingLg),
        if (!order.isPaidInPoints) ...[
          Row(
            children: [
              Text(AdminStrings.paymentStatus, style: AdminTextStyles.tableHeader),
              const SizedBox(width: AdminConstants.spacingSm),
              AdminStatusChip(label: _paymentStatus.label, color: _paymentStatus.color),
            ],
          ),
          const SizedBox(height: AdminConstants.spacingSm),
          Row(
            children: [
              Expanded(
                child: AdminButton(
                  label: AdminStrings.markPaymentVerified,
                  onPressed: _paymentStatus == PaymentStatus.verified ? null : () => _setPayment(PaymentStatus.verified),
                ),
              ),
              const SizedBox(width: AdminConstants.spacingSm),
              Expanded(
                child: AdminButton(
                  label: AdminStrings.markPaymentRejected,
                  kind: AdminButtonKind.danger,
                  onPressed: _paymentStatus == PaymentStatus.rejected
                      ? null
                      : () => setState(() => _choosingRejectReason = true),
                ),
              ),
            ],
          ),
          if (_choosingRejectReason) ...[
            const SizedBox(height: AdminConstants.spacingMd),
            Text(AdminStrings.rejectReason, style: AdminTextStyles.label),
            const SizedBox(height: AdminConstants.spacingSm),
            AdminOptionChips<String>(
              options: AdminStrings.rejectReasonPresets,
              selected: _rejectPreset,
              labelOf: (r) => r,
              onChanged: (r) => setState(() => _rejectPreset = r),
            ),
            const SizedBox(height: AdminConstants.spacingSm),
            TextField(
              controller: _rejectNote,
              maxLines: 2,
              style: AdminTextStyles.body,
              decoration: const InputDecoration(hintText: AdminStrings.rejectReasonNote),
            ),
            const SizedBox(height: AdminConstants.spacingSm),
            Row(
              children: [
                Expanded(
                  child: AdminButton(
                    label: AdminStrings.markPaymentRejected,
                    kind: AdminButtonKind.danger,
                    onPressed: _confirmReject,
                  ),
                ),
                const SizedBox(width: AdminConstants.spacingSm),
                Expanded(
                  child: AdminButton(
                    label: AdminStrings.cancel,
                    kind: AdminButtonKind.secondary,
                    onPressed: () => setState(() => _choosingRejectReason = false),
                  ),
                ),
              ],
            ),
          ],
          if (_paymentStatus == PaymentStatus.rejected && (order.paymentRejectReason?.isNotEmpty ?? false)) ...[
            const SizedBox(height: AdminConstants.spacingSm),
            Text('${AdminStrings.rejectReason}: ${order.paymentRejectReason}',
                style: AdminTextStyles.caption.copyWith(color: AdminColors.danger)),
          ],
          const SizedBox(height: AdminConstants.spacingLg),
          const Divider(color: AdminColors.border, height: 1),
          const SizedBox(height: AdminConstants.spacingLg),
        ],
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

/// Label + value with a copy button — phones, transaction ids.
class _CopyRow extends StatelessWidget {
  final String label;
  final String value;

  const _CopyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary)),
          const SizedBox(width: AdminConstants.spacingMd),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: SelectableText(value, style: AdminTextStyles.caption)),
                const SizedBox(width: AdminConstants.spacingSm),
                InkWell(
                  onTap: () => Clipboard.setData(ClipboardData(text: value)),
                  child: const Icon(Icons.copy, size: 14, color: AdminColors.gold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final String label;
  final String url;
  final String text;

  const _LinkRow({required this.label, required this.url, this.text = AdminStrings.openLink});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary)),
          InkWell(
            onTap: () => launchUrl(Uri.parse(url), webOnlyWindowName: '_blank'),
            child: Text(
              text,
              style: AdminTextStyles.caption.copyWith(color: AdminColors.gold, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}

String? _explorerUrl(PaymentMethod? method, String txid) => switch (method) {
      PaymentMethod.usdtTrc20 => 'https://tronscan.org/#/transaction/$txid',
      PaymentMethod.usdtBep20 => 'https://bscscan.com/tx/$txid',
      PaymentMethod.usdtErc20 => 'https://etherscan.io/tx/$txid',
      _ => null,
    };

extension on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.pending => AdminStrings.paymentPending,
        PaymentStatus.verified => AdminStrings.paymentVerified,
        PaymentStatus.rejected => AdminStrings.paymentRejected,
      };

  Color get color => switch (this) {
        PaymentStatus.pending => AdminColors.warning,
        PaymentStatus.verified => AdminColors.success,
        PaymentStatus.rejected => AdminColors.danger,
      };
}

/// ✅ / ⚠️ under the totals — the order's amount vs today's prices.
class _CheckNote extends StatelessWidget {
  final OrderCheck check;
  final double total;
  final NumberFormat currency;

  const _CheckNote({required this.check, required this.total, required this.currency});

  @override
  Widget build(BuildContext context) {
    final ok = check.matches(total);
    final color = ok ? AdminColors.success : AdminColors.warning;
    return Padding(
      padding: const EdgeInsets.only(top: AdminConstants.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ok ? Icons.verified_outlined : Icons.warning_amber_rounded, size: 16, color: color),
              const SizedBox(width: AdminConstants.spacingXs),
              Expanded(
                child: Text(ok ? AdminStrings.totalsMatch : AdminStrings.totalsMismatch,
                    style: AdminTextStyles.caption.copyWith(color: color)),
              ),
            ],
          ),
          if (!ok) ...[
            Text(AdminStrings.totalsExpected('${currency.format(check.expectedTotal)} ل.س'), style: AdminTextStyles.caption),
            Text(AdminStrings.totalsMismatchNote,
                style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
