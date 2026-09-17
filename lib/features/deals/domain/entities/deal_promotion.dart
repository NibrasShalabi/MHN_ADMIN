import 'package:equatable/equatable.dart';

class DealPromotion extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final double originalPrice;
  final double discountPercentage;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;

  const DealPromotion({
    required this.id,
    required this.productId,
    required this.productName,
    required this.originalPrice,
    required this.discountPercentage,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  double get discountedPrice => originalPrice * (1 - discountPercentage / 100);
  bool get isExpired => DateTime.now().isAfter(endTime);
  Duration get remaining => endTime.difference(DateTime.now());

  DealPromotion copyWith({bool? isActive}) => DealPromotion(
    id: id,
    productId: productId,
    productName: productName,
    originalPrice: originalPrice,
    discountPercentage: discountPercentage,
    startTime: startTime,
    endTime: endTime,
    isActive: isActive ?? this.isActive,
  );

  @override
  List<Object?> get props => [id, productId, discountPercentage, startTime, endTime, isActive];
}