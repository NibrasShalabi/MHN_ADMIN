import '../../domain/entities/loyalty_rules.dart';
import '../../domain/entities/loyalty_transaction.dart';
import 'loyalty_repository.dart';

class FakeLoyaltyRepository implements LoyaltyRepository {
  LoyaltyRules _rules = const LoyaltyRules();

  final List<LoyaltyTransaction> _transactions = [
    LoyaltyTransaction(
      id: 'LT-1',
      userName: 'أحمد الخطيب',
      userPhone: '0933123456',
      points: 45,
      reason: 'نقاط شراء — طلب ORD-1001',
      reference: 'ORD-1001',
      createdAt: DateTime(2026, 8, 20),
    ),
    LoyaltyTransaction(
      id: 'LT-2',
      userName: 'أحمد الخطيب',
      userPhone: '0933123456',
      points: 50,
      reason: 'نقاط تقييم التطبيق',
      createdAt: DateTime(2026, 8, 21),
    ),
  ];

  @override
  Future<LoyaltyRules> getRules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _rules;
  }

  @override
  Future<void> updateRules(LoyaltyRules rules) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _rules = rules;
  }

  @override
  Future<List<LoyaltyTransaction>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_transactions);
  }

  @override
  Future<void> addCorrection({
    required String userName,
    required String userPhone,
    required int points,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _transactions.add(LoyaltyTransaction(
      id: 'LT-${DateTime.now().millisecondsSinceEpoch}',
      userName: userName,
      userPhone: userPhone,
      points: points,
      reason: reason,
      createdAt: DateTime.now(),
    ));
  }
}