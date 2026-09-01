import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../data/repository/fitness_repository.dart';
import '../../domain/entities/health_program.dart';
import '../cubits/programs_cubit.dart';
import '../cubits/programs_state.dart';
import 'program_form_page.dart';

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

  void _openForm(BuildContext context, ProgramsCubit cubit, {HealthProgram? program}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BlocProvider.value(value: cubit, child: ProgramFormPage(program: program))),
    );
  }

  void _confirmDelete(BuildContext context, ProgramsCubit cubit, HealthProgram program) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AdminColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AdminConstants.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AdminStrings.deleteConfirm, style: AdminTextStyles.body),
              const SizedBox(height: AdminConstants.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: AdminButton(
                      label: AdminStrings.delete,
                      kind: AdminButtonKind.danger,
                      onPressed: () {
                        cubit.deleteProgram(program.id);
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: AdminConstants.spacingSm),
                  Expanded(
                    child: AdminButton(
                      label: AdminStrings.cancel,
                      kind: AdminButtonKind.secondary,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Builder(
              builder: (context) => AdminButton(
                label: AdminStrings.addProgram,
                icon: Icons.add,
                onPressed: () => _openForm(context, context.read<ProgramsCubit>()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        BlocBuilder<ProgramsCubit, ProgramsState>(
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

            final programs = state.programs;
            final cubit = context.read<ProgramsCubit>();

            return AdminDataTable(
              emptyMessage: AdminStrings.noData,
              rowCount: programs.length,
              columns: const [
                AdminColumn(AdminStrings.programTitle, flex: 3),
                AdminColumn(AdminStrings.fieldsCount, flex: 2),
                AdminColumn(AdminStrings.coachWhatsapp, flex: 2),
                AdminColumn('', flex: 1),
              ],
              cellsBuilder: (index) {
                final program = programs[index];
                return [
                  Text(program.title, style: AdminTextStyles.caption),
                  Text('${program.fields.length}', style: AdminTextStyles.caption),
                  Text(program.coachWhatsappUrl.isEmpty ? AdminStrings.none : program.coachWhatsappUrl,
                      style: AdminTextStyles.caption, overflow: TextOverflow.ellipsis),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AdminColors.danger),
                    onPressed: () => _confirmDelete(context, cubit, program),
                  ),
                ];
              },
              onRowTap: (index) => _openForm(context, cubit, program: programs[index]),
            );
          },
        ),
      ],
    );
  }
}