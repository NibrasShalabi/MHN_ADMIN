import '../../../../core/bloc/safe_cubit.dart';

import '../../data/repository/firebase_admin_loyalty_repository.dart';
import '../../data/repository/loyalty_repository.dart';
import 'loyalty_ledger_state.dart';
import '../../../../core/error/admin_error.dart';

class LoyaltyLedgerCubit extends SafeCubit<LoyaltyLedgerState> {
  final LoyaltyRepository _repository;

  LoyaltyLedgerCubit(this._repository) : super(const LoyaltyLedgerState());

  Future<void> load() async {
    emit(state.copyWith(status: LedgerStatus.loading));
    try {
      final transactions = await _repository.getTransactions();
      emit(state.copyWith(
        status: LedgerStatus.loaded,
        transactions: transactions,
        hasMore: transactions.length == FirebaseAdminLoyaltyRepository.pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(status: LedgerStatus.error, errorMessage: AdminError.message(e)));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.transactions.isEmpty) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final more = await _repository.getTransactions(before: state.transactions.last.createdAt);
      emit(state.copyWith(
        transactions: [...state.transactions, ...more],
        hasMore: more.length == FirebaseAdminLoyaltyRepository.pageSize,
        loadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(loadingMore: false, errorMessage: AdminError.message(e)));
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

}