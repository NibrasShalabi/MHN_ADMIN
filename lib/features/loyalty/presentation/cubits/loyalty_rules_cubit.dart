import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/loyalty_repository.dart';
import '../../domain/entities/loyalty_rules.dart';
import 'loyalty_rules_state.dart';

class LoyaltyRulesCubit extends Cubit<LoyaltyRulesState> {
  final LoyaltyRepository _repository;

  LoyaltyRulesCubit(this._repository) : super(const LoyaltyRulesState());

  Future<void> load() async {
    emit(state.copyWith(status: LoyaltyRulesStatus.loading));
    try {
      final rules = await _repository.getRules();
      emit(state.copyWith(status: LoyaltyRulesStatus.loaded, rules: rules));
    } catch (e) {
      emit(state.copyWith(status: LoyaltyRulesStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> update(LoyaltyRules rules) async {
    await _repository.updateRules(rules);
    emit(state.copyWith(rules: rules));
  }
}