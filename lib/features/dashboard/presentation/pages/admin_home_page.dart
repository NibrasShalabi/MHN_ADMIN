import 'package:flutter/material.dart';
import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../about/presentation/pages/about_page.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../categories/presentation/pages/categories_page.dart';
import '../../../fitness/presentation/pages/fitness_page.dart';
import '../../../loyalty/presentation/pages/loyalty_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../presets/presentation/pages/presets_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../suggestions/presentation/pages/suggestions_page.dart';
import '../../../support/presentation/pages/support_page.dart';
import '../../domain/entities/admin_section.dart';
import 'dashboard_page.dart';

/// Hosts the shell and swaps the body by section.
///
/// Sections are filled in one at a time; anything not built yet renders a
/// clearly-labelled stub rather than an empty screen, so it's obvious at a
/// glance what's done and what isn't.
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  AdminSection _section = AdminSection.dashboard;

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      items: AdminSection.values
          .map((s) => AdminNavItem(id: s.name, label: s.label, icon: s.icon))
          .toList(),
      selectedId: _section.name,
      onSelect: (id) => setState(
            () => _section = AdminSection.values.firstWhere((s) => s.name == id),
      ),
      title: _section.label,
      child: _SectionBody(
        section: _section,
        onNavigate: (s) => setState(() => _section = s),
      ),    );
  }
}

class _SectionBody extends StatelessWidget {
  final AdminSection section;
  final ValueChanged<AdminSection> onNavigate;

  const _SectionBody({required this.section, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminConstants.spacingLg),
      child: switch (section) {
        AdminSection.dashboard => DashboardPage(onNavigate: onNavigate),
        AdminSection.products => const ProductsPage(),
        AdminSection.orders => const OrdersPage(),
        AdminSection.categories => const CategoriesPage(),
        AdminSection.suggestions => const SuggestionsPage(),
        AdminSection.support => const SupportPage(),
        AdminSection.fitness => const FitnessPage(),
        AdminSection.loyalty => const LoyaltyPage(),
        AdminSection.presets => const PresetsPage(),
        AdminSection.content => const AboutPage(),
        AdminSection.analytics => const AnalyticsPage(),
      },
    );
  }
}
/// Temporary: shows the variants block on its own so the presets flow can
/// be tried before the full product form exists.


class _Stub extends StatelessWidget {
  final String label;

  const _Stub({required this.label});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.construction_outlined,
                size: 40,
                color: AdminColors.textDisabled,
              ),
              const SizedBox(height: AdminConstants.spacingMd),
              Text(AdminStrings.sectionNotReady, style: AdminTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}