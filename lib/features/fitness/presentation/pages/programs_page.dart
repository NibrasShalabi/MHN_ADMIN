import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_confirm_dialog.dart';
import '../../../../core/widgets/admin_status_chip.dart';
import '../../data/repository/fitness_repository.dart';
import '../../domain/entities/fitness_section.dart';
import '../../domain/entities/health_program.dart';
import '../cubits/programs_cubit.dart';
import '../cubits/programs_state.dart';
import 'program_form_page.dart';

/// The four sections, each with the questions the specialist asks before
/// building a personal plan. Programs saved under other ids (made before
/// the sections were fixed) are listed below so they can be removed.
class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgramsCubit(GetIt.instance<FitnessRepository>())..loadPrograms(),
      child: const _ProgramsView(),
    );
  }
}

class _ProgramsView extends StatelessWidget {
  const _ProgramsView();

  void _edit(BuildContext context, HealthProgram program) {
    final cubit = context.read<ProgramsCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BlocProvider.value(value: cubit, child: ProgramFormPage(program: program))),
    );
  }

  Future<void> _delete(BuildContext context, HealthProgram program) async {
    final cubit = context.read<ProgramsCubit>();
    if (await showAdminConfirm(context, title: AdminStrings.delete, message: AdminStrings.deleteConfirm)) {
      await cubit.deleteProgram(program.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramsCubit, ProgramsState>(
      builder: (context, state) {
        if (state.status == ProgramsStatus.loading || state.status == ProgramsStatus.initial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == ProgramsStatus.error) {
          return Center(child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong));
        }

        final sections = state.programs.where((p) => FitnessSection.byId(p.id) != null).toList();
        final legacy = state.programs.where((p) => FitnessSection.byId(p.id) == null).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AdminStrings.fitnessSectionsHint, style: AdminTextStyles.caption),
            const SizedBox(height: AdminConstants.spacingMd),
            Wrap(
              spacing: AdminConstants.spacingMd,
              runSpacing: AdminConstants.spacingMd,
              children: [
                for (final p in sections)
                  SizedBox(width: 300, child: _SectionCard(program: p, onEdit: () => _edit(context, p))),
              ],
            ),
            if (legacy.isNotEmpty) ...[
              const SizedBox(height: AdminConstants.spacingXl),
              AdminCard(
                title: AdminStrings.legacyPrograms,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(AdminStrings.legacyProgramsHint, style: AdminTextStyles.caption),
                    const SizedBox(height: AdminConstants.spacingSm),
                    for (final p in legacy)
                      Row(
                        children: [
                          Expanded(child: Text(p.title, style: AdminTextStyles.body)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AdminColors.danger),
                            onPressed: () => _delete(context, p),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final HealthProgram program;
  final VoidCallback onEdit;

  const _SectionCard({required this.program, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final ready = program.fields.isNotEmpty;
    return AdminCard(
      title: program.title,
      actions: [
        AdminStatusChip(
          label: ready ? AdminStrings.sectionLive : AdminStrings.sectionNoQuestions,
          color: ready ? AdminColors.success : AdminColors.warning,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${AdminStrings.fieldsCount}: ${program.fields.length}', style: AdminTextStyles.caption),
          const SizedBox(height: AdminConstants.spacingXs),
          Text(
            '${AdminStrings.coachWhatsapp}: ${program.coachWhatsappUrl.isEmpty ? AdminStrings.none : program.coachWhatsappUrl}',
            style: AdminTextStyles.caption,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AdminConstants.spacingMd),
          AdminButton(label: AdminStrings.editQuestions, icon: Icons.edit_note, onPressed: onEdit),
        ],
      ),
    );
  }
}
