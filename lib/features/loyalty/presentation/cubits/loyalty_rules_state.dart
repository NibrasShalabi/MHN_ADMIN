import 'package:equatable/equatable.dart';

import '../../domain/entities/loyalty_rules.dart';

enum LoyaltyRulesStatus { initial, loading, loaded, error }

class LoyaltyRulesState extends Equatable {
  final LoyaltyRulesStatus status;
  final LoyaltyRules rules;
  final String? errorMessage;

  const LoyaltyRulesState({
    this.status = LoyaltyRulesStatus.initial,
    this.rules = const LoyaltyRules(),
    this.errorMessage,
  });

  LoyaltyRulesState copyWith({
    LoyaltyRulesStatus? status,
    LoyaltyRules? rules,
    String? errorMessage,
  }) {
    return LoyaltyRulesState(
      status: status ?? this.status,
      rules: rules ?? this.rules,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, rules, errorMessage];
}