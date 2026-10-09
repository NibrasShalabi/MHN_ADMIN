import '../../domain/entities/order.dart';
import '../../domain/entities/order_batch.dart';
import '../../domain/entities/order_check.dart';

abstract class OrdersRepository {
  Future<List<Order>> getOrders();
  Future<void> updateOrderStatus(
      String orderId,
      OrderStatus status, {
        String? note,
        bool notifyCustomer = false,
      });

  Future<void> updatePaymentStatus(String orderId, PaymentStatus status);

  /// Recomputes what the order should cost from current prices and shipping.
  Future<OrderCheck> checkOrder(Order order);

  // Batches (8.1) — grouping orders for a bulk status change + message.
  Future<List<OrderBatch>> getBatches();
  Future<void> createBatch(String name, List<String> orderIds);
  Future<void> deleteBatch(String id);
}