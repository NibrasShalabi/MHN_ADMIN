import '../../domain/entities/order.dart';
import '../../domain/entities/order_batch.dart';
import '../../presentation/widgets/order_message.dart';
import 'orders_repository.dart';

class FakeOrdersRepository implements OrdersRepository {
  final List<Order> _orders = [
    Order(
      id: 'ORD-1001',
      customerName: 'أحمد الخطيب',
      customerPhone: '0933123456',
      items: const [OrderItem(productName: 'قميص أبيض', quantity: 2)],
      totalPrice: 45000,
      deliveryFee: 3000,
      paymentMethod: PaymentMethod.cashOnDelivery,
      address: 'دمشق - المزة',
      orderDate: DateTime(2026, 8, 20),
      status: OrderStatus.pending,
    ),
    Order(
      id: 'ORD-1002',
      customerName: 'سارة يوسف',
      customerPhone: '0944987654',
      items: const [OrderItem(productName: 'حذاء رياضي', quantity: 1)],
      totalPrice: 60000,
      address: 'حلب - الفرقان',
      orderDate: DateTime(2026, 8, 22),
      status: OrderStatus.onTheWay,
    ),
  ];
  final List<OrderMessage> _messages = [];
  final List<OrderBatch> _batches = [];

  @override
  Future<List<Order>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_orders);
  }

  @override
  Future<void> updateOrderStatus(
      String orderId,
      OrderStatus status, {
        String? note,
        bool notifyCustomer = false,
      }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        status: status,
        statusNote: note,
        notifyCustomer: notifyCustomer,
      );
    }
    if (notifyCustomer && note != null && note.isNotEmpty) {
      _messages.add(OrderMessage(
        id: 'MSG-${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        text: note,
        sentAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<List<OrderBatch>> getBatches() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_batches);
  }

  @override
  Future<void> createBatch(String name, List<String> orderIds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _batches.add(OrderBatch(
      id: 'BATCH-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      orderIds: orderIds,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<void> deleteBatch(String id) async {
    // Ungroups only — the orders themselves are untouched, same as
    // removing a label rather than deleting what it was on.
    await Future.delayed(const Duration(milliseconds: 200));
    _batches.removeWhere((b) => b.id == id);
  }
}