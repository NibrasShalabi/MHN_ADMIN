import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/orders_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_batch.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository _repository;

  OrdersCubit(this._repository) : super(const OrdersState());

  Future<void> loadOrders() async {
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final orders = await _repository.getOrders();
      final batches = await _repository.getBatches();
      emit(state.copyWith(status: OrdersStatus.loaded, orders: orders, batches: batches));
    } catch (e) {
      emit(state.copyWith(status: OrdersStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> updateStatus(
      String orderId,
      OrderStatus status, {
        String? note,
        bool notifyCustomer = false,
      }) async {
    await _repository.updateOrderStatus(orderId, status, note: note, notifyCustomer: notifyCustomer);
    await loadOrders();
  }

  Future<void> createBatch(String name, List<String> orderIds) async {
    await _repository.createBatch(name, orderIds);
    await loadOrders();
  }

  Future<void> deleteBatch(String id) async {
    await _repository.deleteBatch(id);
    await loadOrders();
  }

  /// The same status-change call [updateStatus] makes, once per order in
  /// the batch — a batch's "unified message" is that shared note, sent to
  /// every order (and so every customer) it contains, in one action.
  Future<void> applyBulkStatus(
      OrderBatch batch,
      OrderStatus status, {
        String? note,
        bool notifyCustomer = false,
      }) async {
    for (final orderId in batch.orderIds) {
      await _repository.updateOrderStatus(orderId, status, note: note, notifyCustomer: notifyCustomer);
    }
    await loadOrders();
  }
}