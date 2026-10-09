import 'package:flutter/material.dart';

import '../../../../core/constants/admin_strings.dart';

enum AdminSection {
  dashboard,
  products,
  categories,
  orders,
  shipping,
  payments,
  suggestions,
  support,
  reviews,
  fitness,
  loyalty,
  presets,
  homeBanners,
  suppliers,
  analytics,
  deals,
}

extension AdminSectionInfo on AdminSection {
  String get label => switch (this) {
    AdminSection.dashboard => AdminStrings.navDashboard,
    AdminSection.products => AdminStrings.navProducts,
    AdminSection.categories => AdminStrings.navCategories,
    AdminSection.orders => AdminStrings.navOrders,
    AdminSection.shipping => AdminStrings.navShipping,
    AdminSection.payments => AdminStrings.navPayments,
    AdminSection.suggestions => AdminStrings.navSuggestions,
    AdminSection.support => AdminStrings.navSupport,
    AdminSection.reviews => 'التقييمات',
    AdminSection.fitness => AdminStrings.navFitness,
    AdminSection.loyalty => AdminStrings.navLoyalty,
    AdminSection.presets => AdminStrings.navPresets,
    AdminSection.homeBanners => AdminStrings.navHomeBanners,
    AdminSection.suppliers => AdminStrings.navSuppliers,
    AdminSection.analytics => AdminStrings.navAnalytics,
    AdminSection.deals => AdminStrings.navDeals,
  };

  IconData get icon => switch (this) {
    AdminSection.dashboard => Icons.dashboard_outlined,
    AdminSection.products => Icons.inventory_2_outlined,
    AdminSection.categories => Icons.category_outlined,
    AdminSection.orders => Icons.receipt_long_outlined,
    AdminSection.shipping => Icons.local_shipping_outlined,
    AdminSection.payments => Icons.account_balance_wallet_outlined,
    AdminSection.suggestions => Icons.lightbulb_outline,
    AdminSection.support => Icons.headset_mic_outlined,
    AdminSection.reviews => Icons.star_outline,
    AdminSection.fitness => Icons.spa_outlined,
    AdminSection.loyalty => Icons.local_fire_department_outlined,
    AdminSection.presets => Icons.tune_outlined,
    AdminSection.homeBanners => Icons.view_carousel_outlined,
    AdminSection.suppliers => Icons.storefront_outlined,
    AdminSection.analytics => Icons.insights_outlined,
    AdminSection.deals => Icons.local_fire_department_outlined,
  };
}