import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_data_table.dart';
import '../../../../core/widgets/admin_side_panel.dart';
import '../../data/repository/promo_banners_repository.dart';
import '../../domain/entities/promo_banner.dart';
import '../cubits/promo_banners_cubit.dart';
import '../cubits/promo_banners_state.dart';
import '../widgets/promo_banner_form_panel.dart';

class PromoBannersPage extends StatelessWidget {
  const PromoBannersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      PromoBannersCubit(GetIt.instance<PromoBannersRepository>())..loadBanners(),
      child: const _PromoBannersView(),
    );
  }
}

class _PromoBannersView extends StatelessWidget {
  const _PromoBannersView();

  void _openForm(BuildContext context, PromoBannersCubit cubit, {PromoBanner? banner}) {
    showAdminSidePanel(
      context,
      title: banner == null ? AdminStrings.addBanner : AdminStrings.editBanner,
      child: PromoBannerFormPanel(banner: banner, cubit: cubit),
    );
  }

  void _confirmDelete(BuildContext context, PromoBannersCubit cubit, PromoBanner banner) {
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
                        cubit.deleteBanner(banner.id);
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
                label: AdminStrings.addBanner,
                icon: Icons.add,
                onPressed: () => _openForm(context, context.read<PromoBannersCubit>()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        BlocBuilder<PromoBannersCubit, PromoBannersState>(
          builder: (context, state) {
            if (state.status == PromoBannersStatus.loading ||
                state.status == PromoBannersStatus.initial) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == PromoBannersStatus.error) {
              return Center(
                child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong),
              );
            }

            final banners = state.banners;
            final cubit = context.read<PromoBannersCubit>();

            return AdminDataTable(
              emptyMessage: AdminStrings.noData,
              rowCount: banners.length,
              columns: const [
                AdminColumn('', flex: 1),
                AdminColumn(AdminStrings.bannerTitle, flex: 3),
                AdminColumn(AdminStrings.bannerOrder, flex: 1),
                AdminColumn('', flex: 1),
              ],
              cellsBuilder: (index) {
                final banner = banners[index];
                return [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                    child: banner.imageBytes != null
                        ? Image.memory(
                      banner.imageBytes!,
                      width: 48,
                      height: 32,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 48,
                      height: 32,
                      color: AdminColors.surfaceRaised,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 16,
                        color: AdminColors.textDisabled,
                      ),
                    ),
                  ),
                  Text(banner.title ?? '—', style: AdminTextStyles.caption),
                  Text('${banner.order}', style: AdminTextStyles.caption),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AdminColors.danger),
                    onPressed: () => _confirmDelete(context, cubit, banner),
                  ),
                ];
              },
              onRowTap: (index) => _openForm(context, cubit, banner: banners[index]),
            );
          },
        ),
      ],
    );
  }
}