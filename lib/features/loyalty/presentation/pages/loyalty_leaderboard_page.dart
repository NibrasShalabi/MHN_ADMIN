import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/error/admin_error.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../data/repository/loyalty_repository.dart';
import '../../domain/entities/loyalty_leader.dart';

/// Top balances straight from the customers' accounts.
class LoyaltyLeaderboardPage extends StatefulWidget {
  const LoyaltyLeaderboardPage({super.key});

  @override
  State<LoyaltyLeaderboardPage> createState() => _LoyaltyLeaderboardPageState();
}

class _LoyaltyLeaderboardPageState extends State<LoyaltyLeaderboardPage> {
  // Top 3 get a medal tone instead of the plain rank number.
  static const List<Color> _medalColors = [
    AdminColors.gold,
    Color(0xFFC0C0C0),
    Color(0xFFCD7F32),
  ];

  late final Future<List<LoyaltyLeader>> _leaders = GetIt.instance<LoyaltyRepository>().topBalances();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LoyaltyLeader>>(
      future: _leaders,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text(AdminError.message(snap.error!)));
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final leaders = snap.data!;
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
              Text('${leader.points}', style: AdminTextStyles.caption.copyWith(color: AdminColors.gold)),
            ];
          },
        );
      },
    );
  }
}
