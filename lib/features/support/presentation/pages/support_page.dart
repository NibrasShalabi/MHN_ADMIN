import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../../../core/widgets/admin_side_panel.dart';
import '../../../../core/widgets/admin_status_chip.dart';
import '../../data/repository/support_repository.dart';
import '../cubits/support_cubit.dart';
import '../cubits/support_state.dart';
import '../widgets/support_details_panel.dart';
import '../widgets/support_x.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupportCubit(GetIt.instance<SupportRepository>())..loadMessages(),
      child: const _SupportView(),
    );
  }
}

class _SupportView extends StatelessWidget {
  const _SupportView();

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return BlocBuilder<SupportCubit, SupportState>(
      builder: (context, state) {
        if (state.status == SupportPageStatus.loading ||
            state.status == SupportPageStatus.initial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == SupportPageStatus.error) {
          return Center(child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong));
        }

        final messages = state.messages;
        final cubit = context.read<SupportCubit>();

        return AdminDataTable(
          emptyMessage: AdminStrings.noData,
          rowCount: messages.length,
          columns: const [
            AdminColumn(AdminStrings.sentBy, flex: 2),
            AdminColumn(AdminStrings.supportTopic, flex: 2),
            AdminColumn(AdminStrings.orderDate, flex: 2),
            AdminColumn(AdminStrings.orderStatus, flex: 2),
          ],
          cellsBuilder: (index) {
            final message = messages[index];
            return [
              Text(message.sentBy, style: AdminTextStyles.caption),
              Text(message.topic.label, style: AdminTextStyles.caption),
              Text(dateFormat.format(message.createdAt), style: AdminTextStyles.caption),
              AdminStatusChip(label: message.status.label, color: message.status.color),
            ];
          },
          onRowTap: (index) {
            final message = messages[index];
            showAdminSidePanel(
              context,
              title: message.topic.label,
              child: SupportDetailsPanel(message: message, cubit: cubit),
            );
          },
        );
      },
    );
  }
}