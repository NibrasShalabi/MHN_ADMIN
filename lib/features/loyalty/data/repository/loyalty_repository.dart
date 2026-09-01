import '../../domain/entities/loyalty_rules.dart';
import '../../domain/entities/loyalty_transaction.dart';

abstract class LoyaltyRepository {
  Future<LoyaltyRules> getRules();
  Future<void> updateRules(LoyaltyRules rules);

  Future<List<LoyaltyTransaction>> getTransactions();
  Future<void> addCorrection({
    required String userName,
    required String userPhone,
    required int points,
    required String reason,
  });
}