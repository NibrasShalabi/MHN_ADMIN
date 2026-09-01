import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../../../core/widgets/admin_side_panel.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../data/repository/loyalty_repository.dart';
import '../cubits/loyalty_ledger_cubit.dart';
import '../cubits/loyalty_ledger_state.dart';
import '../widgets/correction_form_panel.dart';

class LoyaltyLedgerPage extends StatelessWidget {
  const LoyaltyLedgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoyaltyLedgerCubit(GetIt.instance<LoyaltyRepository>())..load(),
      child: const _LoyaltyLedgerView(),
    );
  }
}

class _LoyaltyLedgerView extends StatefulWidget {
  const _LoyaltyLedgerView();

  @override
  State<_LoyaltyLedgerView> createState() => _LoyaltyLedgerViewState();
}

class _LoyaltyLedgerViewState extends State<_LoyaltyLedgerView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCorrectionForm(BuildContext context, LoyaltyLedgerCubit cubit) {
    showAdminSidePanel(
      context,
      title: AdminStrings.addCorrection,
      child: CorrectionFormPanel(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AdminTextInput(
                controller: _searchController,
                hint: AdminStrings.searchByUser,
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
            const SizedBox(width: AdminConstants.spacingMd),
            Builder(
              builder: (context) => AdminButton(
                label: AdminStrings.addCorrection,
                icon: Icons.add,
                onPressed: () => _openCorrectionForm(context, context.read<LoyaltyLedgerCubit>()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        BlocBuilder<LoyaltyLedgerCubit, LoyaltyLedgerState>(
          builder: (context, state) {
            if (state.status == LedgerStatus.loading || state.status == LedgerStatus.initial) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == LedgerStatus.error) {
              return Center(child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong));
            }

            final transactions = _query.isEmpty
                ? state.transactions
                : state.transactions.where((t) => t.userName.contains(_query)).toList();

            final balancesByPhone = <String, int>{};
            for (final t in transactions) {
              balancesByPhone.update(t.userPhone, (v) => v + t.points, ifAbsent: () => t.points);
            }

            return AdminDataTable(
              emptyMessage: AdminStrings.noData,
              rowCount: transactions.length,
              columns: const [
                AdminColumn(AdminStrings.customer, flex: 2),
                AdminColumn(AdminStrings.transactionReason, flex: 3),
                AdminColumn(AdminStrings.transactionDate, flex: 2),
                AdminColumn(AdminStrings.orderTotal, flex: 1),
                AdminColumn(AdminStrings.pointsBalance, flex: 1),
              ],
              cellsBuilder: (index) {
                final t = transactions[index];
                final isPositive = t.points >= 0;
                return [
                  Text(t.userName, style: AdminTextStyles.caption),
                  Text(t.reason, style: AdminTextStyles.caption, overflow: TextOverflow.ellipsis),
                  Text(dateFormat.format(t.createdAt), style: AdminTextStyles.caption),
                  Text(
                    '${isPositive ? '+' : ''}${t.points}',
                    style: AdminTextStyles.caption.copyWith(
                      color: isPositive ? AdminColors.gold : AdminColors.danger,
                    ),
                  ),
                  Text('${balancesByPhone[t.userPhone] ?? 0}', style: AdminTextStyles.caption),
                ];
              },
            );
          },
        ),
      ],
    );
  }
}  