import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../../../core/widgets/admin_side_panel.dart';
import '../../../products/data/repository/products_repository.dart';
import '../../data/repository/presets_repository.dart';
import '../../domain/entities/presets.dart';
import '../cubits/presets_cubit.dart';
import '../cubits/presets_state.dart';
import '../widgets/color_form_panel.dart';
import '../widgets/size_guide_form_panel.dart';
import '../widgets/size_set_form_panel.dart';

enum PresetTab { sizeSets, colors, sizeGuides }

extension PresetTabX on PresetTab {
  String get label => switch (this) {
    PresetTab.sizeSets => AdminStrings.sizeSets,
    PresetTab.colors => AdminStrings.colorPalette,
    PresetTab.sizeGuides => AdminStrings.sizeGuides,
  };
}

class PresetsPage extends StatelessWidget {
  const PresetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PresetsCubit(
        GetIt.instance<PresetsRepository>(),
        GetIt.instance<ProductsRepository>(),
      )..load(),
      child: const _PresetsView(),
    );
  }
}

class _PresetsView extends StatefulWidget {
  const _PresetsView();

  @override
  State<_PresetsView> createState() => _PresetsViewState();
}

class _PresetsViewState extends State<_PresetsView> {
  PresetTab _tab = PresetTab.sizeSets;

  void _showCannotDelete(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AdminColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AdminConstants.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AdminStrings.cannotDeletePreset, style: AdminTextStyles.body, textAlign: TextAlign.center),
              const SizedBox(height: AdminConstants.spacingSm),
              Text('${AdminStrings.usedByProducts} $count ${AdminStrings.productsWord}',
                  style: AdminTextStyles.caption),
              const SizedBox(height: AdminConstants.spacingLg),
              AdminButton(label: AdminStrings.confirm, onPressed: () => Navigator.of(dialogContext).pop()),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onDelete) {
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
                        onDelete();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminOptionChips<PresetTab>(
          options: PresetTab.values,
          selected: _tab,
          allowNone: false,
          labelOf: (t) => t.label,
          onChanged: (t) => setState(() => _tab = t ?? _tab),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        BlocBuilder<PresetsCubit, PresetsState>(
          builder: (context, state) {
            if (state.status == PresetsStatus.loading || state.status == PresetsStatus.initial) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == PresetsStatus.error) {
              return Center(child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong));
            }

            final cubit = context.read<PresetsCubit>();

            return switch (_tab) {
              PresetTab.sizeSets => _SizeSetsTab(
                sizeSets: state.presets.sizeSets,
                usageOf: cubit.sizeSetUsage,
                cubit: cubit,
                onCannotDelete: (c) => _showCannotDelete(context, c),
                onConfirmDelete: (fn) => _confirmDelete(context, fn),
              ),
              PresetTab.colors => _ColorsTab(
                colors: state.presets.colors,
                usageOf: cubit.colorUsage,
                cubit: cubit,
                onCannotDelete: (c) => _showCannotDelete(context, c),
                onConfirmDelete: (fn) => _confirmDelete(context, fn),
              ),
              PresetTab.sizeGuides => _SizeGuidesTab(
                guides: state.presets.sizeGuides,
                usageOf: cubit.sizeGuideUsage,
                cubit: cubit,
                onCannotDelete: (c) => _showCannotDelete(context, c),
                onConfirmDelete: (fn) => _confirmDelete(context, fn),
              ),
            };
          },
        ),
      ],
    );
  }
}

class _SizeSetsTab extends StatelessWidget {
  final List<SizeSet> sizeSets;
  final int Function(String) usageOf;
  final PresetsCubit cubit;
  final void Function(int) onCannotDelete;
  final void Function(VoidCallback) onConfirmDelete;

  const _SizeSetsTab({
    required this.sizeSets,
    required this.usageOf,
    required this.cubit,
    required this.onCannotDelete,
    required this.onConfirmDelete,
  });

  void _openForm(BuildContext context, {SizeSet? sizeSet}) {
    showAdminSidePanel(
      context,
      title: sizeSet == null ? AdminStrings.addSizeSet : AdminStrings.presetName,
      child: SizeSetFormPanel(sizeSet: sizeSet, cubit: cubit),
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
            AdminButton(label: AdminStrings.addSizeSet, icon: Icons.add, onPressed: () => _openForm(context)),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminDataTable(
          emptyMessage: AdminStrings.noData,
          rowCount: sizeSets.length,
          columns: const [
            AdminColumn(AdminStrings.presetName, flex: 3),
            AdminColumn(AdminStrings.sizeSet, flex: 4),
            AdminColumn(AdminStrings.productsCount, flex: 2),
            AdminColumn('', flex: 1),
          ],
          cellsBuilder: (index) {
            final set = sizeSets[index];
            final usage = usageOf(set.id);
            return [
              Text(set.name, style: AdminTextStyles.caption),
              Text(set.sizes.join('، '), style: AdminTextStyles.caption, overflow: TextOverflow.ellipsis),
              Text('$usage', style: AdminTextStyles.caption),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AdminColors.danger),
                onPressed: () {
                  if (usage > 0) {
                    onCannotDelete(usage);
                  } else {
                    onConfirmDelete(() => cubit.deleteSizeSet(set.id));
                  }
                },
              ),
            ];
          },
          onRowTap: (index) => _openForm(context, sizeSet: sizeSets[index]),
        ),
      ],
    );
  }
}

class _ColorsTab extends StatelessWidget {
  final List<PaletteColor> colors;
  final int Function(String) usageOf;
  final PresetsCubit cubit;
  final void Function(int) onCannotDelete;
  final void Function(VoidCallback) onConfirmDelete;

  const _ColorsTab({
    required this.colors,
    required this.usageOf,
    required this.cubit,
    required this.onCannotDelete,
    required this.onConfirmDelete,
  });

  void _openForm(BuildContext context, {PaletteColor? color}) {
    showAdminSidePanel(
      context,
      title: color == null ? AdminStrings.addColor : AdminStrings.colorName,
      child: ColorFormPanel(color: color, cubit: cubit),
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
            AdminButton(label: AdminStrings.addColor, icon: Icons.add, onPressed: () => _openForm(context)),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        Wrap(
          spacing: AdminConstants.spacingLg,
          runSpacing: AdminConstants.spacingLg,
          children: colors.map((color) {
            final usage = usageOf(color.id);
            return InkWell(
              onTap: () => _openForm(context, color: color),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Color(color.value),
                          shape: BoxShape.circle,
                          border: Border.all(color: AdminColors.border, width: AdminConstants.borderThin),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            if (usage > 0) {
                              onCannotDelete(usage);
                            } else {
                              onConfirmDelete(() => cubit.deleteColor(color.id));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(color: AdminColors.danger, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminConstants.spacingXs),
                  Text(color.name, style: AdminTextStyles.caption),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SizeGuidesTab extends StatelessWidget {
  final List<SizeGuideTemplate> guides;
  final int Function(String) usageOf;
  final PresetsCubit cubit;
  final void Function(int) onCannotDelete;
  final void Function(VoidCallback) onConfirmDelete;

  const _SizeGuidesTab({
    required this.guides,
    required this.usageOf,
    required this.cubit,
    required this.onCannotDelete,
    required this.onConfirmDelete,
  });

  void _openForm(BuildContext context, {SizeGuideTemplate? guide}) {
    showAdminSidePanel(
      context,
      title: guide == null ? AdminStrings.addSizeGuide : AdminStrings.presetName,
      child: SizeGuideFormPanel(guide: guide, cubit: cubit),
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
            AdminButton(label: AdminStrings.addSizeGuide, icon: Icons.add, onPressed: () => _openForm(context)),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminDataTable(
          emptyMessage: AdminStrings.noData,
          rowCount: guides.length,
          columns: const [
            AdminColumn(AdminStrings.presetName, flex: 3),
            AdminColumn(AdminStrings.rows, flex: 2),
            AdminColumn(AdminStrings.productsCount, flex: 2),
            AdminColumn('', flex: 1),
          ],
          cellsBuilder: (index) {
            final guide = guides[index];
            final usage = usageOf(guide.id);
            return [
              Text(guide.name, style: AdminTextStyles.caption),
              Text('${guide.rows.length}', style: AdminTextStyles.caption),
              Text('$usage', style: AdminTextStyles.caption),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AdminColors.danger),
                onPressed: () {
                  if (usage > 0) {
                    onCannotDelete(usage);
                  } else {
                    onConfirmDelete(() => cubit.deleteSizeGuide(guide.id));
                  }
                },
              ),
            ];
          },
          onRowTap: (index) => _openForm(context, guide: guides[index]),
        ),
      ],
    );
  }
}