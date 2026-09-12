import 'package:equatable/equatable.dart';

import '../../domain/entities/supplier.dart';

enum SuppliersStatus { initial, loading, loaded, error }

class SuppliersState extends Equatable {
  final SuppliersStatus status;
  final List<Supplier> suppliers;
  final String? errorMessage;

  const SuppliersState({
    this.status = SuppliersStatus.initial,
    this.suppliers = const [],
    this.errorMessage,
  });

  SuppliersState copyWith({
    SuppliersStatus? status,
    List<Supplier>? suppliers,
    String? errorMessage,
  }) {
    return SuppliersState(
      status: status ?? this.status,
      suppliers: suppliers ?? this.suppliers,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, suppliers, errorMessage];
}