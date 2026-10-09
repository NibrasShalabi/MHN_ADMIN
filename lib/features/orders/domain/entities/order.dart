import 'package:equatable/equatable.dart';

enum OrderStatus { pending, confirmed, preparing, onTheWay, delivered, delayed, cancelled }
enum PaymentMethod { cashOnDelivery, bankTransfer, usdtTrc20, usdtBep20, usdtErc20, shamCash }

class OrderItem extends Equatable {
  final String productName;
  final int quantity;

  const OrderItem({required this.productName, required this.quantity});

  @override
  List<Object?> get props => [productName, quantity];
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
  final double totalPrice;

  /// Loyalty-store items, priced in points — charged when the order is confirmed.
  final int pointsTotal;
  final double deliveryFee;
  final PaymentMethod? paymentMethod;
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
    this.pointsTotal = 0,
    this.deliveryFee = 0,
     this.paymentMethod,
     this.statusNote,
    required this.address,
    required this.orderDate,
    required this.status,
    this.notifyCustomer = false,
  });

  /// Same order with the customer details filled in — for orders placed
  /// before checkout started saving them.
  Order withCustomer(Map<String, dynamic> user) {
    String? text(String key) {
      final v = (user[key] as String?)?.trim();
      return v == null || v.isEmpty ? null : v;
    }

    final name = '${text('fullName') ?? ''} ${text('familyName') ?? ''}'.trim();
    return Order(
      id: id,
      customerName: name.isEmpty ? customerName : name,
      customerPhone: text('phone') ?? customerPhone,
      customerSecondaryPhone: text('secondaryPhone'),
      governorate: text('governorate'),
      area: text('area'),
      gender: text('gender'),
      txid: txid,
      receiptUrl: receiptUrl,
      items: items,
      totalPrice: totalPrice,
      pointsTotal: pointsTotal,
      deliveryFee: deliveryFee,
      paymentMethod: paymentMethod,
      address: address,
      orderDate: orderDate,
      status: status,
      statusNote: statusNote,
      notifyCustomer: notifyCustomer,
    );
  }

  Order copyWith({OrderStatus? status, String? statusNote, bool? notifyCustomer}) {
    return Order(
      id: id,
      customerName: customerName,
      customerPhone: customerPhone,
      customerSecondaryPhone: customerSecondaryPhone,
      governorate: governorate,
      area: area,
      gender: gender,
      txid: txid,
      receiptUrl: receiptUrl,
      items: items,
      totalPrice: totalPrice,
      pointsTotal: pointsTotal,
      deliveryFee: deliveryFee,
      paymentMethod: paymentMethod,
      address: address,
      orderDate: orderDate,
      status: status ?? this.status,
      statusNote: statusNote,
      notifyCustomer: notifyCustomer ?? this.notifyCustomer,
    );
  }
  @override
  List<Object?> get props => [
    id,
    customerName,
    customerPhone,
    customerSecondaryPhone,
    governorate,
    area,
    gender,
    txid,
    receiptUrl,
    items,
    totalPrice,
    pointsTotal,
    deliveryFee,
    paymentMethod,
    address,
    orderDate,
    status,
    statusNote,
    notifyCustomer,
  ];
}