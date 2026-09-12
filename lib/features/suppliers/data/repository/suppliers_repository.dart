import '../../domain/entities/supplier.dart';

abstract class SuppliersRepository {
  Future<List<Supplier>> getSuppliers();
  Future<void> addSupplier(Supplier supplier);
  Future<void> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(String id);
}