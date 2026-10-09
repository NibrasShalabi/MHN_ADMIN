import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../domain/entities/order.dart';
import '../../domain/entities/insufficient_points_exception.dart';
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
    final orders = snap.docs.map(_orderFromDoc).toList();

    // Older orders don't carry the customer snapshot — fetch those users
    // in batches of 30 (one read per 30 customers, not per order).
    final missing = {
      for (final d in snap.docs)
        if (d.data()['customerName'] == null) d.data()['userId'] as String?,
    }.whereType<String>().toList();
    if (missing.isEmpty) return orders;

    final users = <String, Map<String, dynamic>>{};
    for (var i = 0; i < missing.length; i += 30) {
      final chunk = missing.sublist(i, (i + 30).clamp(0, missing.length));
      final page = await _db.collection('users').where(FieldPath.documentId, whereIn: chunk).get();
      for (final u in page.docs) {
        users[u.id] = u.data();
      }
    }
    final userIdOf = {for (final d in snap.docs) d.id: d.data()['userId'] as String?};
    return [
      for (final o in orders)
        if (users[userIdOf[o.id]] case final user?) o.withCustomer(user) else o,
    ];
  }

  /// Status change in one transaction, with the loyalty side-effects:
  /// - confirmed → points are charged once (`pointsDeducted` on the order)
  /// - cancelled after a charge → refunded once (`pointsRefunded`)
  /// The cost is recomputed from the products themselves, never from what
  /// the client wrote on the order.
  @override
  Future<void> updateOrderStatus(
      String orderId,
      OrderStatus status, {
        String? note,
        bool notifyCustomer = false,
      }) async {
    final orderRef = _db.collection('orders').doc(orderId);

    await _db.runTransaction((tx) async {
      // ===== Reads =====
      final order = (await tx.get(orderRef)).data() ?? const <String, dynamic>{};
      final userId = order['userId'] as String?;
      final userRef = userId == null ? null : _db.collection('users').doc(userId);
      final deducted = (order['pointsDeducted'] as num?)?.toInt() ?? 0;
      final awarded = (order['pointsAwarded'] as num?)?.toInt() ?? 0;

      final charging = status == OrderStatus.confirmed && deducted == 0 && userRef != null;
      final refunding = status == OrderStatus.cancelled && deducted > 0 && order['pointsRefunded'] != true;

      final cost = charging ? await _pointsCost(tx, order['items'] as List? ?? const []) : 0;

      // Purchase reward: once, when delivered; taken back if cancelled afterwards.
      final awarding = status == OrderStatus.delivered && awarded == 0 && userRef != null;
      final revoking = status == OrderStatus.cancelled && awarded > 0 && order['pointsAwardRevoked'] != true;
      final reward = awarding ? await _purchaseReward(tx, (order['total'] as num? ?? 0).toDouble()) : 0;
      if (cost > 0) {
        final balance = ((await tx.get(userRef!)).data()?['loyaltyPoints'] as num?)?.toInt() ?? 0;
        if (balance < cost) throw InsufficientPointsException(required: cost, balance: balance);
      }

      // ===== Writes =====
      tx.update(orderRef, {
        'status': status.name,
        'statusNote': note,
        if (cost > 0) 'pointsDeducted': cost,
        if (refunding) 'pointsRefunded': true,
        if (reward > 0) 'pointsAwarded': reward,
        if (revoking) 'pointsAwardRevoked': true,
      });

      if (cost > 0) _movePoints(tx, userRef!, userId!, -cost, id: 'order_$orderId', orderId: orderId, reason: 'شراء من متجر الولاء');
      if (refunding) _movePoints(tx, userRef!, userId!, deducted, id: 'refund_$orderId', orderId: orderId, reason: 'استرجاع نقاط طلب ملغى');

      if (reward > 0) _movePoints(tx, userRef!, userId!, reward, id: 'reward_$orderId', orderId: orderId, reason: 'نقاط عملية شراء');
      if (revoking) _movePoints(tx, userRef!, userId!, -awarded, id: 'reward_revoke_$orderId', orderId: orderId, reason: 'إلغاء نقاط طلب ملغى');

      if (notifyCustomer && note != null && userId != null) {
        tx.set(_db.collection('admin_messages').doc(), {
          'type': 'order_update',
          'userId': userId,
          'orderId': orderId,
          'body': note,
          'sentAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    });
  }

  Future<int> _pointsCost(Transaction tx, List items) async {
    var total = 0;
    for (final item in items.cast<Map<String, dynamic>>()) {
      final productId = item['productId'] as String?;
      if (productId == null) continue;
      final product = (await tx.get(_db.collection('products').doc(productId))).data();
      if (product?['pricing'] != 'points') continue;
      total += ((product!['price'] as num? ?? 0) * (item['quantity'] as num? ?? 1)).round();
    }
    return total;
  }

  /// Admin's purchase rule from config/loyaltyRules: a fixed amount per
  /// order, or a percentage of the money total. Points items don't count.
  Future<int> _purchaseReward(Transaction tx, double moneyTotal) async {
    final rules = (await tx.get(_db.collection('config').doc('loyaltyRules'))).data() ?? const {};
    if (rules['purchaseRuleEnabled'] == false || moneyTotal <= 0) return 0;
    final value = (rules['purchaseValue'] as num? ?? 0).toDouble();
    final points = rules['purchaseIsPercentage'] == true ? moneyTotal * value / 100 : value;
    return points.round();
  }

  /// Fixed transaction id per order — a retry can never charge or refund twice.
  void _movePoints(Transaction tx, DocumentReference userRef, String userId, int points,
      {required String id, required String orderId, required String reason}) {
    tx.update(userRef, {'loyaltyPoints': FieldValue.increment(points)});
    tx.set(_db.collection('loyaltyTransactions').doc(id), {
      'userId': userId,
      'orderId': orderId,
      'points': points,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
      customerSecondaryPhone: d['customerSecondaryPhone'] as String?,
      governorate: d['governorate'] as String?,
      area: d['area'] as String?,
      gender: d['gender'] as String?,
      txid: d['txid'] as String?,
      receiptUrl: d['receiptUrl'] as String?,
      address: d['address'] as String? ?? '',
      totalPrice: (d['total'] as num? ?? 0).toDouble(),
      pointsTotal: (d['pointsTotal'] as num?)?.toInt() ?? 0,
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
      'cashOnDelivery' || 'cod' => PaymentMethod.cashOnDelivery,
      'bankTransfer' => PaymentMethod.bankTransfer,
      'trc20' => PaymentMethod.usdtTrc20,
      'bep20' => PaymentMethod.usdtBep20,
      'erc20' => PaymentMethod.usdtErc20,
      'sham_cash' => PaymentMethod.shamCash,
      _ => null,
    };
  }
}