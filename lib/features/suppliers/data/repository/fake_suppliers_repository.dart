import '../../domain/entities/supplier.dart';
import 'suppliers_repository.dart';

class FakeSuppliersRepository implements SuppliersRepository {
  final List<Supplier> _suppliers = [
    const Supplier(id: 'SUP-1', name: 'محل أحمد', description: 'إلكترونيات وإكسسوارات أصلية بضمان الوكيل.'),
    const Supplier(id: 'SUP-2', name: 'صنعة سارة', description: 'منتجات يدوية محلية الصنع بلمسة شخصية.'),
  ];

  @override
  Future<List<Supplier>> getSuppliers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_suppliers);
  }

  @override
  Future<void> addSupplier(Supplier supplier) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _suppliers.add(supplier);
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _suppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) _suppliers[index] = supplier;
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _suppliers.removeWhere((s) => s.id == id);
  }
}