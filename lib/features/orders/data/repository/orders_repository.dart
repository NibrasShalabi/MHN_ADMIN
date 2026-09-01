import '../../domain/entities/order.dart';

abstract class OrdersRepository {
  Future<List<Order>> getOrders();
  Future<void> updateOrderStatus(
      String orderId,
      OrderStatus status, {
        String? note,
        bool notifyCustomer = false,
      });
}