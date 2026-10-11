import 'package:equatable/equatable.dart';

import '../../domain/entities/loyalty_transaction.dart';

enum LedgerStatus { initial, loading, loaded, error }

class LoyaltyLedgerState extends Equatable {
  final LedgerStatus status;
  final List<LoyaltyTransaction> transactions;
  final String? errorMessage;

  /// The last page was full, so older entries may exist.
  final bool hasMore;
  final bool loadingMore;

  const LoyaltyLedgerState({
    this.status = LedgerStatus.initial,
    this.transactions = const [],
    this.errorMessage,
    this.hasMore = false,
    this.loadingMore = false,
  });

  LoyaltyLedgerState copyWith({
    LedgerStatus? status,
    List<LoyaltyTransaction>? transactions,
    String? errorMessage,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return LoyaltyLedgerState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage, hasMore, loadingMore];
}