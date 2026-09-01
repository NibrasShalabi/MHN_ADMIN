import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../domain/entities/dynamic_form_field.dart';
import '../../domain/entities/health_program.dart';
import '../cubits/programs_cubit.dart';
import '../widgets/field_builder.dart';
import '../widgets/form_preview.dart';

class ProgramFormPage extends StatefulWidget {
  final HealthProgram? program;

  const ProgramFormPage({super.key, this.program});

  @override
  State<ProgramFormPage> createState() => _ProgramFormPageState();
}

class _ProgramFormPageState extends State<ProgramFormPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _introController;
  late final TextEditingController _whatsappController;
  late List<DynamicFormField> _fields;
  late Set<String> _suggestedIds;

  bool get _isEditing => widget.program != null;

  @override
  void initState() {
    super.initState();
    final p = widget.program;
    _titleController = TextEditingController(text: p?.title ?? '');
    _introController = TextEditingController(text: p?.intro ?? '');
    _whatsappController = TextEditingController(text: p?.coachWhatsappUrl ?? '');
    _fields = [...?p?.fields];
    _suggestedIds = {...?p?.suggestedProgramIds};
  }

  @override
  void dispose() {
    _titleController.dispose();
    _introController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _save() {
    final program = HealthProgram(
      id: widget.program?.id ?? 'HP-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      intro: _introController.text.trim(),
      fields: _fields,
      coachWhatsappUrl: _whatsappController.text.trim(),
      suggestedProgramIds: _suggestedIds.toList(),
    );
    final cubit = context.read<ProgramsCubit>();
    _isEditing ? cubit.updateProgram(program) : cubit.addProgram(program);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final otherPrograms =
    context.watch<ProgramsCubit>().state.programs.where((p) => p.id != widget.program?.id).toList();

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      appBar: AppBar(
        backgroundColor: AdminColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminColors.gold),
        title: Text(_isEditing ? AdminStrings.editProgram : AdminStrings.addProgram, style: AdminTextStyles.pageTitle),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AdminConstants.maxContentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AdminConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminCard(
                  title: AdminStrings.basicInfo,
                  child: Column(
                    children: [
                      AdminField(
                        label: AdminStrings.programTitle,
                        isRequired: true,
                        child: AdminTextInput(controller: _titleController, onChanged: (_) => setState(() {})),
                      ),
                      AdminField(
                        label: AdminStrings.programIntro,
                        child: AdminTextInput(controller: _introController, maxLines: 3, onChanged: (_) => setState(() {})),
                      ),
                      AdminField(
                        label: AdminStrings.coachWhatsapp,
                        child: AdminTextInput(controller: _whatsappController),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminConstants.spacingLg),
                if (otherPrograms.isNotEmpty)
                  AdminCard(
                    title: AdminStrings.suggestedProgramsAfterSubmit,
                    child: AdminChoiceChips<String>(
                      options: otherPrograms.map((p) => p.id).toList(),
                      selected: _suggestedIds,
                      labelOf: (id) => otherPrograms.firstWhere((p) => p.id == id).title,
                      onChanged: (ids) => setState(() => _suggestedIds = ids),
                    ),
                  ),
                const SizedBox(height: AdminConstants.spacingLg),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final builder = AdminCard(
                      title: AdminStrings.programFields,
                      child: FieldBuilder(fields: _fields, onChanged: (f) => setState(() => _fields = f)),
                    );
                    final preview = FormPreview(title: _titleController.text, intro: _introController.text, fields: _fields);

                    if (constraints.maxWidth <= 900) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [builder, const SizedBox(height: AdminConstants.spacingLg), preview],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: builder),
                        const SizedBox(width: AdminConstants.spacingLg),
                        Expanded(child: preview),
                      ],
                    ); 
                  },
                ),
                const SizedBox(height: AdminConstants.spacingLg),
                AdminButton(label: AdminStrings.save, onPressed: _save),
                const SizedBox(height: AdminConstants.spacingLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}