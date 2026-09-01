import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_status_chip.dart';
import '../../domain/entities/support_message.dart';
import '../cubits/support_cubit.dart';
import 'support_x.dart';

class SupportDetailsPanel extends StatefulWidget {
  final SupportMessage message;
  final SupportCubit cubit;

  const SupportDetailsPanel({super.key, required this.message, required this.cubit});

  @override
  State<SupportDetailsPanel> createState() => _SupportDetailsPanelState();
}

class _SupportDetailsPanelState extends State<SupportDetailsPanel> {
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _resolve() {
    final reply = _replyController.text.trim();
    widget.cubit.markResolved(widget.message.id, reply: reply.isEmpty ? null : reply);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(message.topic.label, style: AdminTextStyles.sectionTitle)),
            AdminStatusChip(label: message.status.label, color: message.status.color),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        _InfoRow(label: AdminStrings.sentBy, value: message.sentBy),
        _InfoRow(label: AdminStrings.orderDate, value: dateFormat.format(message.createdAt)),
        const SizedBox(height: AdminConstants.spacingLg),
        const Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: AdminConstants.spacingLg),
        Text(AdminStrings.supportBody, style: AdminTextStyles.tableHeader),
        const SizedBox(height: AdminConstants.spacingSm),
        Text(message.body, style: AdminTextStyles.body),
        const SizedBox(height: AdminConstants.spacingLg),
        if (message.status == SupportStatus.open) ...[
          const Divider(color: AdminColors.border, height: 1),
          const SizedBox(height: AdminConstants.spacingLg),
          Text(AdminStrings.supportReply, style: AdminTextStyles.tableHeader),
          const SizedBox(height: AdminConstants.spacingSm),
          TextField(
            controller: _replyController,
            maxLines: 3,
            style: AdminTextStyles.body,
            decoration: const InputDecoration(hintText: AdminStrings.supportReply),
          ),
          const SizedBox(height: AdminConstants.spacingMd),
          AdminButton(label: AdminStrings.markResolved, onPressed: _resolve),
        ] else if (message.reply != null && message.reply!.isNotEmpty) ...[
          const Divider(color: AdminColors.border, height: 1),
          const SizedBox(height: AdminConstants.spacingLg),
          Text(AdminStrings.supportReply, style: AdminTextStyles.tableHeader),
          const SizedBox(height: AdminConstants.spacingSm),
          Text(message.reply!, style: AdminTextStyles.body),
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