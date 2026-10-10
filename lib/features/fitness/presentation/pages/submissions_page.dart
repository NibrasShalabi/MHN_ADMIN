import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../../../core/widgets/admin_side_panel.dart';
import '../../../../core/widgets/admin_status_chip.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../domain/entities/fitness_submission.dart';
import '../cubits/submissions_cubit.dart';
import '../cubits/submissions_state.dart';

extension SubmissionStatusColor on SubmissionStatus {
  Color get color => switch (this) {
        SubmissionStatus.pending => AdminColors.danger,
        SubmissionStatus.contacted => AdminColors.gold,
        SubmissionStatus.closed => AdminColors.textDisabled,
      };
}

/// Fitness requests, newest first. The cubit is provided by [FitnessPage]
/// so the tab can show the count of new ones.
class SubmissionsPage extends StatefulWidget {
  const SubmissionsPage({super.key});

  @override
  State<SubmissionsPage> createState() => _SubmissionsPageState();
}

class _SubmissionsPageState extends State<SubmissionsPage> {
  static final DateFormat _date = DateFormat('yyyy/MM/dd · HH:mm', 'ar');
  SubmissionStatus? _filter = SubmissionStatus.pending;

  void _open(BuildContext context, FitnessSubmission s) {
    final cubit = context.read<SubmissionsCubit>();
    showAdminSidePanel(
      context,
      title: s.programTitle,
      child: BlocProvider.value(value: cubit, child: SubmissionDetails(path: s.path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubmissionsCubit, SubmissionsState>(
      builder: (context, state) {
        if (state.status == SubmissionsStatus.loading || state.status == SubmissionsStatus.initial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == SubmissionsStatus.error) {
          return Center(child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong));
        }

        final rows = state.submissions.where((s) => _filter == null || s.status == _filter).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminOptionChips<SubmissionStatus>(
              options: SubmissionStatus.values,
              selected: _filter,
              labelOf: (s) => s == SubmissionStatus.pending ? '${s.label} (${state.newCount})' : s.label,
              onChanged: (s) => setState(() => _filter = s),
            ),
            const SizedBox(height: AdminConstants.spacingMd),
            AdminDataTable(
              emptyMessage: AdminStrings.noData,
              rowCount: rows.length,
              columns: const [
                AdminColumn(AdminStrings.submissionDate, flex: 2),
                AdminColumn(AdminStrings.submissionProgram, flex: 2),
                AdminColumn(AdminStrings.submittedBy, flex: 2),
                AdminColumn(AdminStrings.submissionStatus, flex: 1),
              ],
              cellsBuilder: (i) {
                final s = rows[i];
                return [
                  Text(_date.format(s.submittedAt), style: AdminTextStyles.caption),
                  Text(s.programTitle, style: AdminTextStyles.caption),
                  Text(s.customerName.isEmpty ? '—' : s.customerName, style: AdminTextStyles.caption),
                  AdminStatusChip(label: s.status.label, color: s.status.color),
                ];
              },
              onRowTap: (i) => _open(context, rows[i]),
            ),
          ],
        );
      },
    );
  }
}

/// Everything the customer sent, plus the actions: WhatsApp her, reply
/// into her messages, move the request along.
class SubmissionDetails extends StatefulWidget {
  final String path;

  const SubmissionDetails({super.key, required this.path});

  @override
  State<SubmissionDetails> createState() => _SubmissionDetailsState();
}

class _SubmissionDetailsState extends State<SubmissionDetails> {
  final _reply = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _run(Future<bool> Function() action, String done) async {
    setState(() => _busy = true);
    final ok = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? done : AdminStrings.somethingWentWrong)));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SubmissionsCubit>();
    final s = cubit.state.submissions.firstWhere((x) => x.path == widget.path);
    final whatsapp = s.whatsappUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AdminConstants.spacingMd),
          decoration: BoxDecoration(
            color: AdminColors.danger.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
            border: Border.all(color: AdminColors.danger, width: AdminConstants.borderThin),
          ),
          child: Text(AdminStrings.healthDataRestricted, style: AdminTextStyles.caption),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        _Row(AdminStrings.submittedBy, s.customerName.isEmpty ? '—' : s.customerName),
        _Row(AdminStrings.customerPhoneLabel, s.customerPhone.isEmpty ? '—' : s.customerPhone, copyable: true),
        if (s.governorate case final g?) _Row(AdminStrings.customerGovernorateLabel, g),
        _Row(AdminStrings.submissionDate, DateFormat('yyyy/MM/dd · HH:mm', 'ar').format(s.submittedAt)),
        const SizedBox(height: AdminConstants.spacingMd),
        AdminOptionChips<SubmissionStatus>(
          options: SubmissionStatus.values,
          selected: s.status,
          allowNone: false,
          labelOf: (x) => x.label,
          onChanged: (x) => x == null || x == s.status || _busy
              ? null
              : _run(() => cubit.setStatus(s, x), AdminStrings.saved),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        const Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: AdminConstants.spacingLg),
        Text(AdminStrings.submissionAnswers, style: AdminTextStyles.tableHeader),
        const SizedBox(height: AdminConstants.spacingSm),
        for (final a in s.answers) _Row(a.label, a.value.isEmpty ? '—' : a.value),
        const SizedBox(height: AdminConstants.spacingLg),
        if (whatsapp != null)
          AdminButton(
            label: AdminStrings.openWhatsapp,
            icon: Icons.chat_outlined,
            onPressed: () => launchUrl(Uri.parse(whatsapp), mode: LaunchMode.externalApplication),
          ),
        const SizedBox(height: AdminConstants.spacingLg),
        Text(AdminStrings.fitnessReplyLabel, style: AdminTextStyles.label),
        const SizedBox(height: AdminConstants.spacingSm),
        AdminTextInput(controller: _reply, maxLines: 4, hint: AdminStrings.fitnessReplyHint, onChanged: (_) => setState(() {})),
        const SizedBox(height: AdminConstants.spacingSm),
        AdminButton(
          label: AdminStrings.fitnessReplySend,
          icon: Icons.send_outlined,
          kind: AdminButtonKind.secondary,
          onPressed: _busy || _reply.text.trim().isEmpty
              ? null
              : () => _run(() async {
                    final ok = await cubit.reply(s, _reply.text.trim());
                    if (ok) _reply.clear();
                    return ok;
                  }, AdminStrings.fitnessReplySent),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;

  const _Row(this.label, this.value, {this.copyable = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary)),
          ),
          Expanded(flex: 3, child: SelectableText(value, style: AdminTextStyles.caption)),
          if (copyable)
            InkWell(
              onTap: () => Clipboard.setData(ClipboardData(text: value)),
              child: const Icon(Icons.copy, size: 16, color: AdminColors.gold),
            ),
        ],
      ),
    );
  }
}
