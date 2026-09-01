import 'package:flutter/material.dart';

import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../domain/entities/order.dart';

extension OrderStatusX on OrderStatus {
  String get label =>
      switch (this) {
        OrderStatus.pending => AdminStrings.statusPending,
        OrderStatus.confirmed => AdminStrings.statusConfirmed,
        OrderStatus.preparing => AdminStrings.statusPreparing,
        OrderStatus.onTheWay => AdminStrings.statusOutForDelivery,
        OrderStatus.delivered => AdminStrings.statusDelivered,
        OrderStatus.delayed => AdminStrings.statusDelayed,
        OrderStatus.cancelled => AdminStrings.statusCancelled,
      };

  Color get color =>
      switch (this) {
        OrderStatus.pending => AdminColors.gold,
        OrderStatus.confirmed => AdminColors.gold,
        OrderStatus.preparing => AdminColors.gold,
        OrderStatus.onTheWay => AdminColors.primary,
        OrderStatus.delivered => AdminColors.textSecondary,
        OrderStatus.delayed => AdminColors.gold,
        OrderStatus.cancelled => AdminColors.danger,
      };
}