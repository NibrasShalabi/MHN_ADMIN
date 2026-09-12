import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/suppliers_repository.dart';
import '../../domain/entities/supplier.dart';
import 'suppliers_state.dart';

class SuppliersCubit extends Cubit<SuppliersState> {
  final SuppliersRepository _repository;

  SuppliersCubit(this._repository) : super(const SuppliersState());

  Future<void> load() async {
    emit(state.copyWith(status: SuppliersStatus.loading));
    try {
      final suppliers = await _repository.getSuppliers();
      emit(state.copyWith(status: SuppliersStatus.loaded, suppliers: suppliers));
    } catch (e) {
      emit(state.copyWith(status: SuppliersStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    await _repository.addSupplier(supplier);
    await load();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _repository.updateSupplier(supplier);
    await load();
  }

  Future<void> deleteSupplier(String id) async {
    await _repository.deleteSupplier(id);
    await load();
  }
}