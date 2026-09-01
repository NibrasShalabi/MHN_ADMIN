import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../data/repository/fitness_repository.dart';
import '../../domain/entities/fitness_submission.dart';
import '../cubits/submissions_cubit.dart';
import '../cubits/submissions_state.dart';

class SubmissionsPage extends StatelessWidget {
  const SubmissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubmissionsCubit(GetIt.instance<FitnessRepository>())..loadSubmissions(),
      child: const _SubmissionsView(),
    );
  }
}

class _SubmissionsView extends StatelessWidget {
  const _SubmissionsView();

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

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

        final submissions = state.submissions;

        return AdminDataTable(
          emptyMessage: AdminStrings.noData,
          rowCount: submissions.length,
          columns: const [
            AdminColumn(AdminStrings.submissionDate, flex: 2),
            AdminColumn(AdminStrings.submissionProgram, flex: 3),
            AdminColumn(AdminStrings.submittedBy, flex: 2),
          ],
          cellsBuilder: (index) {
            final s = submissions[index];
            return [
              Text(dateFormat.format(s.submittedAt), style: AdminTextStyles.caption),
              Text(s.programTitle, style: AdminTextStyles.caption),
              Text(s.submittedByName, style: AdminTextStyles.caption),
            ];
          },
          onRowTap: (index) => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SubmissionDetailPage(submission: submissions[index])),
          ),
        );
      },
    );
  }
}

class SubmissionDetailPage extends StatelessWidget {
  final FitnessSubmission submission;

  const SubmissionDetailPage({super.key, required this.submission});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      appBar: AppBar(
        backgroundColor: AdminColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminColors.gold),
        title: Text(submission.programTitle, style: AdminTextStyles.pageTitle),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AdminConstants.maxContentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AdminConstants.spacingLg),
            child: Column(
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
                Text(AdminStrings.submittedBy, style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary)),
                Text(submission.submittedByName, style: AdminTextStyles.body),
                const SizedBox(height: AdminConstants.spacingMd),
                Text(AdminStrings.submissionDate, style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary)),
                Text(dateFormat.format(submission.submittedAt), style: AdminTextStyles.body),
                const SizedBox(height: AdminConstants.spacingLg),
                const Divider(color: AdminColors.border, height: 1),
                const SizedBox(height: AdminConstants.spacingLg),
                Text(AdminStrings.submissionAnswers, style: AdminTextStyles.tableHeader),
                const SizedBox(height: AdminConstants.spacingSm),
                ...submission.answers.entries.map(
                      (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: AdminTextStyles.caption.copyWith(color: AdminColors.textSecondary)),
                        Text('${e.value}', style: AdminTextStyles.caption),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AdminConstants.spacingLg),
                AdminButton(
                  label: AdminStrings.copyWhatsapp,
                  icon: Icons.chat_outlined,
                  onPressed: () => Clipboard.setData(ClipboardData(text: submission.submittedByWhatsapp)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}