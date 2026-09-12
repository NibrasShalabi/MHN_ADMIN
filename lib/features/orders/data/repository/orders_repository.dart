import '../../domain/entities/order.dart';
import '../../domain/entities/order_batch.dart';

abstract class OrdersRepository {
  Future<List<Order>> getOrders();
  Future<void> updateOrderStatus(
      String orderId,
      OrderStatus status, {
        String? note,
        bool notifyCustomer = false,
      });

  // Batches (8.1) — grouping orders for a bulk status change + message.
  Future<List<OrderBatch>> getBatches();
  Future<void> createBatch(String name, List<String> orderIds);
  Future<void> deleteBatch(String id);
}