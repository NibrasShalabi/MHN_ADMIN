import 'package:equatable/equatable.dart';

import '../../domain/entities/loyalty_transaction.dart';

enum LedgerStatus { initial, loading, loaded, error }

class LoyaltyLedgerState extends Equatable {
  final LedgerStatus status;
  final List<LoyaltyTransaction> transactions;
  final String? errorMessage;

  const LoyaltyLedgerState({
    this.status = LedgerStatus.initial,
    this.transactions = const [],
    this.errorMessage,
  });

  LoyaltyLedgerState copyWith({
    LedgerStatus? status,
    List<LoyaltyTransaction>? transactions,
    String? errorMessage,
  }) {
    return LoyaltyLedgerState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage];
}