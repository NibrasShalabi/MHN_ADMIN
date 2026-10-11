import '../../../../core/bloc/safe_cubit.dart';

import '../../data/repository/firebase_admin_orders_repository.dart';
import '../../data/repository/orders_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/insufficient_points_exception.dart';
import '../../domain/entities/order_check.dart';
import '../../domain/entities/payment_not_verified_exception.dart';
import '../../domain/entities/order_batch.dart';
import '../../../../core/constants/admin_strings.dart';
import 'orders_state.dart';
import '../../../../core/error/admin_error.dart';

class OrdersCubit extends SafeCubit<OrdersState> {
  final OrdersRepository _repository;

  OrdersCubit(this._repository) : super(const OrdersState());

  Future<void> loadOrders() async {
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final orders = await _repository.getOrders();
      final batches = await _repository.getBatches();
      emit(state.copyWith(
        status: OrdersStatus.loaded,
        orders: orders,
        batches: batches,
        hasMore: orders.length == FirebaseAdminOrdersRepository.pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(status: OrdersStatus.error, errorMessage: AdminError.message(e)));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.orders.isEmpty) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final more = await _repository.getOrders(before: state.orders.last.orderDate);
      emit(state.copyWith(
        orders: [...state.orders, ...more],
        hasMore: more.length == FirebaseAdminOrdersRepository.pageSize,
        loadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(loadingMore: false, errorMessage: AdminError.message(e)));
    }
  }

  Future<void> updateStatus(
      String orderId,
      OrderStatus status, {
        String? note,
        bool notifyCustomer = false,
      }) async {
    try {
      await _repository.updateOrderStatus(orderId, status, note: note, notifyCustomer: notifyCustomer);
      // Patched locally — reloading every order after each click was N reads.
      emit(state.copyWith(orders: [
        for (final o in state.orders) o.id == orderId ? o.copyWith(status: status, statusNote: note) : o,
      ]));
    } on PaymentNotVerifiedException {
      emit(state.copyWith(errorMessage: AdminStrings.paymentNotVerified));
    } on InsufficientPointsException catch (e) {
      emit(state.copyWith(errorMessage: AdminStrings.insufficientPoints(e.required, e.balance)));
    } catch (e) {
      emit(state.copyWith(errorMessage: AdminError.message(e)));
    }
  }

  Future<void> updatePaymentStatus(Order order, PaymentStatus status, {String? reason}) async {
    try {
      await _repository.updatePaymentStatus(order, status, reason: reason);
      emit(state.copyWith(orders: [
        for (final o in state.orders) o.id == order.id ? o.copyWith(paymentStatus: status) : o,
      ]));
    } catch (e) {
      emit(state.copyWith(errorMessage: AdminError.message(e)));
    }
  }

  Future<OrderCheck> checkOrder(Order order) => _repository.checkOrder(order);

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
    // One by one so a single order short on points doesn't block the rest.
    for (final orderId in batch.orderIds) {
      await updateStatus(orderId, status, note: note, notifyCustomer: notifyCustomer);
    }
  }
}