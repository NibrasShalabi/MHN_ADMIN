import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../data/repository/about_repository.dart';
import '../../domain/entities/about_content.dart';
import '../cubits/about_cubit.dart';
import '../cubits/about_state.dart';
import '../widgets/about_preview.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AboutCubit(GetIt.instance<AboutRepository>())..load(),
      child: const _AboutView(),
    );
  }
}

class _AboutView extends StatefulWidget {
  const _AboutView();

  @override
  State<_AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<_AboutView> {
  late final TextEditingController _heroTitleController;
  late final TextEditingController _heroSubtitleController;
  late final TextEditingController _missionController;
  late final TextEditingController _sourceController;
  late final TextEditingController _contactController;
  AboutContent? _content;

  void _initFrom(AboutContent content) {
    if (_content != null) return;
    _content = content;
    _heroTitleController = TextEditingController(text: content.heroTitle);
    _heroSubtitleController = TextEditingController(text: content.heroSubtitle);
    _missionController = TextEditingController(text: content.mission);
    _sourceController = TextEditingController(text: content.source);
    _contactController = TextEditingController(text: content.contactText);
  }

  @override
  void dispose() {
    if (_content != null) {
      _heroTitleController.dispose();
      _heroSubtitleController.dispose();
      _missionController.dispose();
      _sourceController.dispose();
      _contactController.dispose();
    }
    super.dispose();
  }

  void _addGoal(AboutCubit cubit, AboutContent content) {
    final goals = [
      ...content.goals,
      AboutGoal(
        id: 'G-${DateTime.now().millisecondsSinceEpoch}',
        title: '',
        description: '',
        icon: GoalIcon.quality,
      ),
    ];
    setState(() => _content = content.copyWith(goals: goals));
  }

  void _removeGoal(AboutCubit cubit, AboutContent content, String id) {
    final goals = content.goals.where((g) => g.id != id).toList();
    setState(() => _content = content.copyWith(goals: goals));
  }

  void _updateGoal(AboutContent content, AboutGoal goal) {
    final goals = content.goals.map((g) => g.id == goal.id ? goal : g).toList();
    setState(() => _content = content.copyWith(goals: goals));
  }

  void _reorderGoals(AboutContent content, int oldIndex, int newIndex) {
    final goals = [...content.goals];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = goals.removeAt(oldIndex);
    goals.insert(newIndex, item);
    setState(() => _content = content.copyWith(goals: goals));
  }

  void _save(AboutCubit cubit) {
    final updated = _content!.copyWith(
      heroTitle: _heroTitleController.text.trim(),
      heroSubtitle: _heroSubtitleController.text.trim(),
      mission: _missionController.text.trim(),
      source: _sourceController.text.trim(),
      contactText: _contactController.text.trim(),
    );
    cubit.save(updated);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AboutCubit, AboutState>(
      builder: (context, state) {
        if (state.status == AboutStatus.loading || state.status == AboutStatus.initial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == AboutStatus.error) {
          return Center(child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong));
        }

        _initFrom(state.content);
        final cubit = context.read<AboutCubit>();
        final content = _content!;

        final form = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminCard(
              title: AdminStrings.basicInfo,
              child: Column(
                children: [
                  AdminField(
                    label: AdminStrings.aboutHeroTitle,
                    child: AdminTextInput(controller: _heroTitleController, onChanged: (_) => setState(() {})),
                  ),
                  AdminField(
                    label: AdminStrings.aboutHeroSubtitle,
                    child: AdminTextInput(controller: _heroSubtitleController, onChanged: (_) => setState(() {})),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminCard(
              title: AdminStrings.aboutMission,
              child: AdminTextInput(controller: _missionController, maxLines: 4, onChanged: (_) => setState(() {})),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminCard(
              title: AdminStrings.aboutGoalsIntro,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (content.goals.isEmpty)
                    Text(AdminStrings.noData, style: AdminTextStyles.caption)
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: content.goals.length,
                      onReorder: (o, n) => _reorderGoals(content, o, n),
                      itemBuilder: (context, index) => _GoalRow(
                        key: ValueKey(content.goals[index].id),
                        index: index,
                        goal: content.goals[index],
                        onChanged: (g) => _updateGoal(content, g),
                        onRemove: () => _removeGoal(cubit, content, content.goals[index].id),
                      ),
                    ),
                  const SizedBox(height: AdminConstants.spacingSm),
                  AdminButton(
                    label: AdminStrings.addGoal,
                    icon: Icons.add,
                    kind: AdminButtonKind.secondary,
                    onPressed: () => _addGoal(cubit, content),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminCard(
              title: AdminStrings.aboutSource,
              child: AdminTextInput(controller: _sourceController, maxLines: 3, onChanged: (_) => setState(() {})),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminCard(
              title: AdminStrings.contactText,
              child: AdminTextInput(controller: _contactController, maxLines: 2, onChanged: (_) => setState(() {})),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminButton(label: AdminStrings.save, onPressed: () => _save(cubit)),
          ],
        );

        final preview = AboutPreview(
          content: content.copyWith(
            heroTitle: _heroTitleController.text,
            heroSubtitle: _heroSubtitleController.text,
            mission: _missionController.text,
            source: _sourceController.text,
            contactText: _contactController.text,
          ),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 900) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [form, const SizedBox(height: AdminConstants.spacingLg), preview],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: form),
                const SizedBox(width: AdminConstants.spacingLg),
                Expanded(child: preview),
              ],
            );
          },
        );
      },
    );
  }
}

class _GoalRow extends StatefulWidget {
  final int index;
  final AboutGoal goal;
  final ValueChanged<AboutGoal> onChanged;
  final VoidCallback onRemove;

  const _GoalRow({
    super.key,
    required this.index,
    required this.goal,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_GoalRow> createState() => _GoalRowState();
}

class _GoalRowState extends State<_GoalRow> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _descController = TextEditingController(text: widget.goal.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;

    return Container(
      margin: const EdgeInsets.only(bottom: AdminConstants.spacingMd),
      padding: const EdgeInsets.all(AdminConstants.spacingMd),
      decoration: BoxDecoration(
        color: AdminColors.canvas,
        borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
        border: Border.all(color: AdminColors.border, width: AdminConstants.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ReorderableDragStartListener(
                index: widget.index,
                child: const Padding(
                  padding: EdgeInsets.only(left: AdminConstants.spacingSm),
                  child: Icon(Icons.drag_handle, color: AdminColors.textSecondary, size: 20),
                ),
              ),
              Expanded(
                child: AdminTextInput(
                  controller: _titleController,
                  hint: AdminStrings.goalTitle,
                  onChanged: (v) => widget.onChanged(goal.copyWith(title: v)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AdminColors.danger),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          const SizedBox(height: AdminConstants.spacingSm),
          AdminTextInput(
            controller: _descController,
            hint: AdminStrings.goalDescription,
            maxLines: 2,
            onChanged: (v) => widget.onChanged(goal.copyWith(description: v)),
          ),
          const SizedBox(height: AdminConstants.spacingSm),
          Text(AdminStrings.goalIcon, style: AdminTextStyles.caption),
          const SizedBox(height: AdminConstants.spacingXs),
          Wrap(
            spacing: AdminConstants.spacingSm,
            children: GoalIcon.values
                .map((i) => InkWell(
              onTap: () => widget.onChanged(goal.copyWith(icon: i)),
              child: Container(
                padding: const EdgeInsets.all(AdminConstants.spacingSm),
                decoration: BoxDecoration(
                  color: i == goal.icon ? AdminColors.primary : AdminColors.surface,
                  borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                  border: Border.all(
                    color: i == goal.icon ? AdminColors.gold : AdminColors.border,
                    width: AdminConstants.borderThin,
                  ),
                ),
                child: Icon(i.data, size: 18, color: AdminColors.textPrimary),
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
