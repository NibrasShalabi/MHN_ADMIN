import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../data/repository/loyalty_repository.dart';
import '../../domain/entities/loyalty_transaction.dart';
import '../cubits/loyalty_ledger_cubit.dart';
import '../cubits/loyalty_ledger_state.dart';

class LoyaltyLeaderboardPage extends StatelessWidget {
  const LoyaltyLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoyaltyLedgerCubit(GetIt.instance<LoyaltyRepository>())..load(),
      child: const _LeaderboardView(),
    );
  }
}

class _LeaderEntry {
  final String name;
  final String phone;
  final int totalPoints;

  const _LeaderEntry({required this.name, required this.phone, required this.totalPoints});
}

class _LeaderboardView extends StatelessWidget {
  const _LeaderboardView();

  // Top 3 get a medal tone instead of the plain rank number — the same
  // "the number carries the meaning" idea as the ledger's +/- coloring.
  static const List<Color> _medalColors = [
    AdminColors.gold,
    Color(0xFFC0C0C0),
    Color(0xFFCD7F32),
  ];

  List<_LeaderEntry> _rank(List<LoyaltyTransaction> transactions) {
    final totals = <String, int>{};
    final names = <String, String>{};
    for (final t in transactions) {
      totals.update(t.userPhone, (v) => v + t.points, ifAbsent: () => t.points);
      names[t.userPhone] = t.userName;
    }
    final entries = totals.entries
        .map((e) => _LeaderEntry(name: names[e.key] ?? '', phone: e.key, totalPoints: e.value))
        .where((e) => e.totalPoints > 0)
        .toList()
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoyaltyLedgerCubit, LoyaltyLedgerState>(
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

        final leaders = _rank(state.transactions);

        return AdminDataTable(
          emptyMessage: AdminStrings.noData,
          rowCount: leaders.length,
          columns: const [
            AdminColumn('#', flex: 1),
            AdminColumn(AdminStrings.customer, flex: 3),
            AdminColumn(AdminStrings.customerPhone, flex: 2),
            AdminColumn(AdminStrings.pointsBalance, flex: 1),
          ],
          cellsBuilder: (index) {
            final leader = leaders[index];
            final medalColor = index < _medalColors.length ? _medalColors[index] : null;
            return [
              Text(
                '${index + 1}',
                style: AdminTextStyles.caption.copyWith(
                  color: medalColor ?? AdminColors.textSecondary,
                  fontWeight: medalColor != null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(leader.name, style: AdminTextStyles.caption),
              Text(leader.phone, style: AdminTextStyles.caption),
              Text(
                '${leader.totalPoints}',
                style: AdminTextStyles.caption.copyWith(color: AdminColors.gold),
              ),
            ];
          },
        );
      },
    );
  }
}