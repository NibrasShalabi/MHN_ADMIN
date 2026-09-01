import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../products/presentation/pages/products_page.dart';
import 'programs_page.dart';
import 'submissions_page.dart';

enum FitnessTab { programs, submissions, supplements }

extension FitnessTabX on FitnessTab {
  String get label => switch (this) {
    FitnessTab.programs => AdminStrings.fitnessPrograms,
    FitnessTab.submissions => AdminStrings.submissions,
    FitnessTab.supplements => AdminStrings.supplements,
  };
}

class FitnessPage extends StatefulWidget {
  const FitnessPage({super.key});

  @override
  State<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage> {
  FitnessTab _tab = FitnessTab.programs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminOptionChips<FitnessTab>(
          options: FitnessTab.values,
          selected: _tab,
          allowNone: false,
          labelOf: (t) => t.label,
          onChanged: (t) => setState(() => _tab = t ?? _tab),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        switch (_tab) {
          FitnessTab.programs => const ProgramsPage(),
          FitnessTab.submissions => const SubmissionsPage(),
          FitnessTab.supplements => const ProductsPage(),
        },
      ],
    );
  }
}