import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/orders_repository.dart';
import '../../domain/entities/order.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository _repository;

  OrdersCubit(this._repository) : super(const OrdersState());

  Future<void> loadOrders() async {
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final orders = await _repository.getOrders();
      emit(state.copyWith(status: OrdersStatus.loaded, orders: orders));
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
}