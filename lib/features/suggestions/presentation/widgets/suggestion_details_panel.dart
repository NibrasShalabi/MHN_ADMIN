import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_status_chip.dart';
import '../../domain/entities/product_suggestion.dart';
import '../cubits/suggestions_cubit.dart';
import 'suggestion_status_x.dart';

class SuggestionDetailsPanel extends StatefulWidget {
  final ProductSuggestion suggestion;
  final SuggestionsCubit cubit;

  const SuggestionDetailsPanel({super.key, required this.suggestion, required this.cubit});

  @override
  State<SuggestionDetailsPanel> createState() => _SuggestionDetailsPanelState();
}

class _SuggestionDetailsPanelState extends State<SuggestionDetailsPanel> {
  bool _showRejectField = false;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _approve() {
    widget.cubit.approve(widget.suggestion.id);
    Navigator.of(context).pop();
  }

  void _confirmReject() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) return;
    widget.cubit.reject(widget.suggestion.id, reason);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = widget.suggestion;
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(suggestion.productName, style: AdminTextStyles.sectionTitle),
            ),
            AdminStatusChip(label: suggestion.status.label, color: suggestion.status.color),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        _InfoRow(label: AdminStrings.suggestedBy, value: suggestion.suggestedBy),
        _InfoRow(label: AdminStrings.orderDate, value: dateFormat.format(suggestion.createdAt)),
        const SizedBox(height: AdminConstants.spacingSm),
        Text(AdminStrings.suggestionLink, style: AdminTextStyles.tableHeader),
        const SizedBox(height: AdminConstants.spacingSm),
        Row(
          children: [
            Expanded(
              child: Text(suggestion.link, style: AdminTextStyles.caption, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: AdminConstants.spacingSm),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: suggestion.link));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AdminStrings.linkCopied)),
                );
              },
              child: const Icon(Icons.copy, size: 16, color: AdminColors.gold),
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        const Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: AdminConstants.spacingLg),
        if (suggestion.status == SuggestionStatus.underReview) ...[
          Row(
            children: [
              Expanded(
                child: AdminButton(
                  label: AdminStrings.approve,
                  onPressed: _approve,
                ),
              ),
              const SizedBox(width: AdminConstants.spacingSm),
              Expanded(
                child: AdminButton(
                  label: AdminStrings.reject,
                  kind: AdminButtonKind.danger,
                  onPressed: () => setState(() => _showRejectField = true),
                ),
              ),
            ],
          ),
          if (_showRejectField) ...[
            const SizedBox(height: AdminConstants.spacingMd),
            TextField(
              controller: _reasonController,
              maxLines: 2,
              style: AdminTextStyles.body,
              decoration: const InputDecoration(hintText: AdminStrings.rejectReason),
            ),
            const SizedBox(height: AdminConstants.spacingSm),
            Row(
              children: [
                Expanded(
                  child: AdminButton(
                    label: AdminStrings.confirm,
                    kind: AdminButtonKind.danger,
                    onPressed: _confirmReject,
                  ),
                ),
                const SizedBox(width: AdminConstants.spacingSm),
                Expanded(
                  child: AdminButton(
                    label: AdminStrings.cancel,
                    kind: AdminButtonKind.secondary,
                    onPressed: () => setState(() => _showRejectField = false),
                  ),
                ),
              ],
            ),
          ],
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