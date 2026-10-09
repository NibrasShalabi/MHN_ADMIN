import 'package:equatable/equatable.dart';

enum OrderStatus { pending, confirmed, preparing, onTheWay, delivered, delayed, cancelled }
enum PaymentMethod { cashOnDelivery, bankTransfer, usdtTrc20, usdtBep20, usdtErc20, shamCash, loyaltyPoints }
enum PaymentStatus { pending, verified, rejected }

class OrderItem extends Equatable {
  final String productId;
  final String productName;
  final int quantity;

  /// Price per piece and supply shipping per piece, as computed at checkout.
  final double unitPrice;
  final double shippingPerUnit;
  final bool isPoints;

  const OrderItem({
    this.productId = '',
    required this.productName,
    required this.quantity,
    this.unitPrice = 0,
    this.shippingPerUnit = 0,
    this.isPoints = false,
  });

  @override
  List<Object?> get props => [productId, productName, quantity, unitPrice, shippingPerUnit, isPoints];
}

class Order extends Equatable {
  final String id;
  final String customerName;
  final String customerPhone;
  final String? customerSecondaryPhone;
  final String? governorate;
  final String? area;
  final String? gender;

  /// Crypto payments: the transaction id the customer pasted.
  final String? txid;

  /// Sham Cash: the uploaded receipt image.
  final String? receiptUrl;
  final List<OrderItem> items;

  /// What the customer must pay: [itemsTotal] + [supplyShipping] + [deliveryFee].
  final double totalPrice;
  final double itemsTotal;
  final double supplyShipping;
  final double deliveryFee;

  /// Loyalty-store items, priced in points — charged when the order is confirmed.
  final int pointsTotal;
  final PaymentMethod? paymentMethod;
  final PaymentStatus paymentStatus;
  final String address;
  final DateTime orderDate;
  final OrderStatus status;
  final String? statusNote;
  final bool notifyCustomer;

  const Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.customerSecondaryPhone,
    this.governorate,
    this.area,
    this.gender,
    this.txid,
    this.receiptUrl,
    required this.items,
    required this.totalPrice,
    this.itemsTotal = 0,
    this.supplyShipping = 0,
    this.deliveryFee = 0,
    this.pointsTotal = 0,
    this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.statusNote,
    required this.address,
    required this.orderDate,
    required this.status,
    this.notifyCustomer = false,
  });

  bool get isPaidInPoints => paymentMethod == PaymentMethod.loyaltyPoints;

  /// Same order with the customer details filled in — for orders placed
  /// before checkout started saving them.
  Order withCustomer(Map<String, dynamic> user) {
    String? text(String key) {
      final v = (user[key] as String?)?.trim();
      return v == null || v.isEmpty ? null : v;
    }

    final name = '${text('fullName') ?? ''} ${text('familyName') ?? ''}'.trim();
    return _copy(
      customerName: name.isEmpty ? customerName : name,
      customerPhone: text('phone') ?? customerPhone,
      customerSecondaryPhone: text('secondaryPhone'),
      governorate: text('governorate'),
      area: text('area'),
      gender: text('gender'),
    );
  }

  Order copyWith({OrderStatus? status, String? statusNote, bool? notifyCustomer, PaymentStatus? paymentStatus}) =>
      _copy(status: status, statusNote: statusNote, notifyCustomer: notifyCustomer, paymentStatus: paymentStatus);

  Order _copy({
    String? customerName,
    String? customerPhone,
    String? customerSecondaryPhone,
    String? governorate,
    String? area,
    String? gender,
    OrderStatus? status,
    String? statusNote,
    bool? notifyCustomer,
    PaymentStatus? paymentStatus,
  }) =>
      Order(
        id: id,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        customerSecondaryPhone: customerSecondaryPhone ?? this.customerSecondaryPhone,
        governorate: governorate ?? this.governorate,
        area: area ?? this.area,
        gender: gender ?? this.gender,
        txid: txid,
        receiptUrl: receiptUrl,
        items: items,
        totalPrice: totalPrice,
        itemsTotal: itemsTotal,
        supplyShipping: supplyShipping,
        deliveryFee: deliveryFee,
        pointsTotal: pointsTotal,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        address: address,
        orderDate: orderDate,
        status: status ?? this.status,
        statusNote: statusNote ?? this.statusNote,
        notifyCustomer: notifyCustomer ?? this.notifyCustomer,
      );

  @override
  List<Object?> get props => [
        id, customerName, customerPhone, customerSecondaryPhone, governorate, area, gender, txid, receiptUrl,
        items, totalPrice, itemsTotal, supplyShipping, deliveryFee, pointsTotal, paymentMethod, paymentStatus,
        address, orderDate, status, statusNote, notifyCustomer,
      ];
}
