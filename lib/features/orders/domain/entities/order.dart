import 'package:equatable/equatable.dart';

enum OrderStatus { pending, confirmed, preparing, onTheWay, delivered, delayed, cancelled }
enum PaymentMethod { cashOnDelivery, bankTransfer }

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
  final List<OrderItem> items;
  final double totalPrice;
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
    required this.items,
    required this.totalPrice,
    this.deliveryFee = 0,
     this.paymentMethod,
     this.statusNote,
    required this.address,
    required this.orderDate,
    required this.status,
    this.notifyCustomer = false,
  });

  Order copyWith({OrderStatus? status, String? statusNote, bool? notifyCustomer}) {
    return Order(
      id: id,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      totalPrice: totalPrice,
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
    items,
    totalPrice,
    deliveryFee,
    paymentMethod,
    address,
    orderDate,
    status,
    statusNote,
    notifyCustomer,
  ];
}