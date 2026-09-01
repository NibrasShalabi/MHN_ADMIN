import 'package:flutter/material.dart';

import '../../../../core/constants/admin_strings.dart';

/// The dashboard's top-level sections.
///
/// One enum drives the sidebar, the page title and the body — three lists
/// that would otherwise drift out of sync every time a section is added.
enum AdminSection {
  dashboard,
  products,
  categories,
  orders,
  suggestions,
  support,
  fitness,
  loyalty,
  presets,
  content,
  analytics,
}

extension AdminSectionInfo on AdminSection {
  String get label => switch (this) {
    AdminSection.dashboard => AdminStrings.navDashboard,
    AdminSection.products => AdminStrings.navProducts,
    AdminSection.categories => AdminStrings.navCategories,
    AdminSection.orders => AdminStrings.navOrders,
    AdminSection.suggestions => AdminStrings.navSuggestions,
    AdminSection.support => AdminStrings.navSupport,
    AdminSection.fitness => AdminStrings.navFitness,
    AdminSection.loyalty => AdminStrings.navLoyalty,
    AdminSection.presets => AdminStrings.navPresets,
    AdminSection.content => AdminStrings.navContent,
    AdminSection.analytics => AdminStrings.navAnalytics,
  };

  IconData get icon => switch (this) {
    AdminSection.dashboard => Icons.dashboard_outlined,
    AdminSection.products => Icons.inventory_2_outlined,
    AdminSection.categories => Icons.category_outlined,
    AdminSection.orders => Icons.receipt_long_outlined,
    AdminSection.suggestions => Icons.lightbulb_outline,
    AdminSection.support => Icons.headset_mic_outlined,
    AdminSection.fitness => Icons.spa_outlined,
    AdminSection.loyalty => Icons.local_fire_department_outlined,
    AdminSection.presets => Icons.tune_outlined,
    AdminSection.content => Icons.article_outlined,
    AdminSection.analytics => Icons.insights_outlined,
  };
}