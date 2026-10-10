import '../../../../core/bloc/safe_cubit.dart';
import '../../data/repository/suppliers_repository.dart';
import '../../domain/entities/supplier.dart';
import 'suppliers_state.dart';

class SuppliersCubit extends SafeCubit<SuppliersState> {
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

  Future<bool> addSupplier(Supplier supplier) => _write(() => _repository.addSupplier(supplier));
  Future<bool> updateSupplier(Supplier supplier) => _write(() => _repository.updateSupplier(supplier));
  Future<bool> deleteSupplier(String id) => _write(() => _repository.deleteSupplier(id));

  Future<bool> _write(Future<void> Function() action) async {
    try {
      await action();
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }
}
