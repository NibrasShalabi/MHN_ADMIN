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
import '../../data/repository/suggestions_repository.dart';
import '../cubits/suggestions_cubit.dart';
import '../cubits/suggestions_state.dart';
import '../widgets/suggestion_details_panel.dart';
import '../widgets/suggestion_status_x.dart';

class SuggestionsPage extends StatelessWidget {
  const SuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SuggestionsCubit(GetIt.instance<SuggestionsRepository>())..loadSuggestions(),
      child: const _SuggestionsView(),
    );
  }
}

class _SuggestionsView extends StatelessWidget {
  const _SuggestionsView();

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return BlocBuilder<SuggestionsCubit, SuggestionsState>(
      builder: (context, state) {
        if (state.status == SuggestionsStatus.loading ||
            state.status == SuggestionsStatus.initial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == SuggestionsStatus.error) {
          return Center(child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong));
        }

        final suggestions = state.suggestions;
        final cubit = context.read<SuggestionsCubit>();

        return AdminDataTable(
          emptyMessage: AdminStrings.noData,
          rowCount: suggestions.length,
          columns: const [
            AdminColumn(AdminStrings.productName, flex: 3),
            AdminColumn(AdminStrings.suggestedBy, flex: 2),
            AdminColumn(AdminStrings.orderDate, flex: 2),
            AdminColumn(AdminStrings.orderStatus, flex: 2),
          ],
          cellsBuilder: (index) {
            final suggestion = suggestions[index];
            return [
              Text(suggestion.productName, style: AdminTextStyles.caption),
              Text(suggestion.suggestedBy, style: AdminTextStyles.caption),
              Text(dateFormat.format(suggestion.createdAt), style: AdminTextStyles.caption),
              AdminStatusChip(label: suggestion.status.label, color: suggestion.status.color),
            ];
          },
          onRowTap: (index) {
            final suggestion = suggestions[index];
            showAdminSidePanel(
              context,
              title: suggestion.productName,
              child: SuggestionDetailsPanel(suggestion: suggestion, cubit: cubit),
            );
          },
        );
      },
    );
  }
}