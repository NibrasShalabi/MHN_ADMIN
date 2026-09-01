import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/loyalty_repository.dart';
import 'loyalty_ledger_state.dart';

class LoyaltyLedgerCubit extends Cubit<LoyaltyLedgerState> {
  final LoyaltyRepository _repository;

  LoyaltyLedgerCubit(this._repository) : super(const LoyaltyLedgerState());

  Future<void> load() async {
    emit(state.copyWith(status: LedgerStatus.loading));
    try {
      final transactions = await _repository.getTransactions();
      emit(state.copyWith(status: LedgerStatus.loaded, transactions: transactions));
    } catch (e) {
      emit(state.copyWith(status: LedgerStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> addCorrection({
    required String userName,
    required String userPhone,
    required int points,
    required String reason,
  }) async {
    await _repository.addCorrection(
      userName: userName,
      userPhone: userPhone,
      points: points,
      reason: reason,
    );
    await load();
  }

  int balanceOf(String userPhone) {
    return state.transactions
        .where((t) => t.userPhone == userPhone)
        .fold(0, (sum, t) => sum + t.points);
  }
}