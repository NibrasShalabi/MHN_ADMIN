import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../products/presentation/pages/products_page.dart';
import 'loyalty_ledger_page.dart';
import 'loyalty_rules_page.dart';

enum LoyaltyTab { gifts, rules, ledger }

extension LoyaltyTabX on LoyaltyTab {
  String get label => switch (this) {
    LoyaltyTab.gifts => AdminStrings.loyaltyGifts,
    LoyaltyTab.rules => AdminStrings.loyaltyRules,
    LoyaltyTab.ledger => AdminStrings.pointsLedger,
  };
}

class LoyaltyPage extends StatefulWidget {
  const LoyaltyPage({super.key});

  @override
  State<LoyaltyPage> createState() => _LoyaltyPageState();
}

class _LoyaltyPageState extends State<LoyaltyPage> {
  LoyaltyTab _tab = LoyaltyTab.gifts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminOptionChips<LoyaltyTab>(
          options: LoyaltyTab.values,
          selected: _tab,
          allowNone: false,
          labelOf: (t) => t.label,
          onChanged: (t) => setState(() => _tab = t ?? _tab),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        switch (_tab) {
          LoyaltyTab.gifts => const ProductsPage(pricingMode: ProductsPricingMode.points),
          LoyaltyTab.rules => const LoyaltyRulesPage(),
          LoyaltyTab.ledger => const LoyaltyLedgerPage(),
        },
      ],
    );
  }
}