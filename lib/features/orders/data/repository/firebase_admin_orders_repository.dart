import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../domain/entities/order.dart';
import '../../domain/entities/order_batch.dart';
import 'orders_repository.dart';

/// Firebase implementation لـ OrdersRepository في الـ Admin
///
/// ملاحظة: بيانات المستخدم (customerName, phone, address)
/// تُقرأ من users/{userId} عند الحاجة — هنا نقرأها من الـ order مباشرة
/// لو ما موجودة بالـ order، Admin بيشوف "غير محدد"
class FirebaseAdminOrdersRepository implements OrdersRepository {
  final FirebaseFirestore _db;

  FirebaseAdminOrdersRepository(this._db);

  // ===== Orders =====

  @override
  Future<List<Order>> getOrders() async {
    final snap = await _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(_orderFromDoc).toList();
  }

  /// تحديث status الطلب + إرسال رسالة للمستخدم (اختياري)
  @override
  Future<void> updateOrderStatus(
      String orderId,
      OrderStatus status, {
        String? note,
        bool notifyCustomer = false,
      }) async {
    final batch = _db.batch();
    final orderRef = _db.collection('orders').doc(orderId);

    // تحديث الـ order
    batch.update(orderRef, {
      'status': status.name,
      'statusNote': note,
    });

    // إرسال رسالة للمستخدم لو طلب الـ admin
    if (notifyCustomer && note != null) {
      final orderDoc = await orderRef.get();
      final userId = orderDoc.data()?['userId'] as String?;

      if (userId != null) {
        final messageRef = _db.collection('admin_messages').doc();
        batch.set(messageRef, {
          'userId': userId,
          'orderId': orderId,
          'body': note,
          'sentAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    }

    await batch.commit();
  }

  // ===== Batches =====

  @override
  Future<List<OrderBatch>> getBatches() async {
    final snap = await _db
        .collection('order_batches')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(_batchFromDoc).toList();
  }

  @override
  Future<void> createBatch(String name, List<String> orderIds) async {
    await _db.collection('order_batches').add({
      'name': name,
      'orderIds': orderIds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteBatch(String id) async {
    await _db.collection('order_batches').doc(id).delete();
  }

  // ===== Mappers =====

  Order _orderFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Order(
      id: doc.id,
      customerName: d['customerName'] as String? ?? 'غير محدد',
      customerPhone: d['customerPhone'] as String? ?? '',
      address: d['address'] as String? ?? '',
      totalPrice: (d['total'] as num? ?? 0).toDouble(),
      deliveryFee: (d['deliveryFee'] as num? ?? 0).toDouble(),
      paymentMethod: _mapPaymentMethod(d['paymentMethod'] as String?),
      orderDate: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: OrderStatus.values.firstWhere(
            (s) => s.name == (d['status'] as String? ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      statusNote: d['statusNote'] as String?,
      items: (d['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem(
        productName: item['name'] as String? ?? '',
        quantity: item['quantity'] as int? ?? 1,
      ))
          .toList(),
    );
  }

  OrderBatch _batchFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return OrderBatch(
      id: doc.id,
      name: d['name'] as String? ?? '',
      orderIds: List<String>.from(d['orderIds'] as List? ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  PaymentMethod? _mapPaymentMethod(String? value) {
    if (value == null) return null;
    return switch (value) {
      'cashOnDelivery' => PaymentMethod.cashOnDelivery,
      'bankTransfer' => PaymentMethod.bankTransfer,
      _ => null,
    };
  }
}