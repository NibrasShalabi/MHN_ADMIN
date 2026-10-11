import '../../domain/entities/loyalty_leader.dart';
import '../../domain/entities/loyalty_rules.dart';
import '../../domain/entities/loyalty_transaction.dart';

abstract class LoyaltyRepository {
  Future<LoyaltyRules> getRules();
  Future<void> updateRules(LoyaltyRules rules);

  /// Newest first, one page at a time; [before] continues the list.
  Future<List<LoyaltyTransaction>> getTransactions({DateTime? before});
  /// Highest balances, read from the customers themselves.
  Future<List<LoyaltyLeader>> topBalances();

  Future<void> addCorrection({
    required String userName,
    required String userPhone,
    required int points,
    required String reason,
  });
}