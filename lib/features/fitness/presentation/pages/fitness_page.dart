import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../data/repository/fitness_repository.dart';
import '../cubits/submissions_cubit.dart';
import '../cubits/submissions_state.dart';
import '../widgets/specialist_whatsapp_card.dart';
import 'programs_page.dart';
import 'submissions_page.dart';

enum FitnessTab { programs, submissions, products }

class FitnessPage extends StatefulWidget {
  const FitnessPage({super.key});

  @override
  State<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage> {
  FitnessTab _tab = FitnessTab.submissions;

  @override
  Widget build(BuildContext context) {
    // Provided here so the tab label can show how many requests are new.
    return BlocProvider(
      create: (_) => SubmissionsCubit(GetIt.instance<FitnessRepository>())..loadSubmissions(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<SubmissionsCubit, SubmissionsState>(
            buildWhen: (a, b) => a.newCount != b.newCount,
            builder: (context, state) => AdminOptionChips<FitnessTab>(
              options: FitnessTab.values,
              selected: _tab,
              allowNone: false,
              labelOf: (t) => switch (t) {
                FitnessTab.programs => AdminStrings.fitnessPrograms,
                FitnessTab.submissions =>
                  state.newCount > 0 ? '${AdminStrings.submissions} (${state.newCount})' : AdminStrings.submissions,
                FitnessTab.products => AdminStrings.fitnessProducts,
              },
              onChanged: (t) => setState(() => _tab = t ?? _tab),
            ),
          ),
          const SizedBox(height: AdminConstants.spacingLg),
          switch (_tab) {
            FitnessTab.programs => const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [SpecialistWhatsappCard(), SizedBox(height: AdminConstants.spacingLg), ProgramsPage()],
              ),
            FitnessTab.submissions => const SubmissionsPage(),
            FitnessTab.products => const ProductsPage(scope: CategoryScope.fitness),
          },
        ],
      ),
    );
  }
}
