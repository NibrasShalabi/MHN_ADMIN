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
import '../../data/repository/loyalty_repository.dart';
import '../cubits/loyalty_rules_cubit.dart';
import '../cubits/loyalty_rules_state.dart';

class LoyaltyRulesPage extends StatelessWidget {
  const LoyaltyRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoyaltyRulesCubit(GetIt.instance<LoyaltyRepository>())..load(),
      child: const _LoyaltyRulesView(),
    );
  }
}

class _LoyaltyRulesView extends StatefulWidget {
  const _LoyaltyRulesView();

  @override
  State<_LoyaltyRulesView> createState() => _LoyaltyRulesViewState();
}

class _LoyaltyRulesViewState extends State<_LoyaltyRulesView> {
  late final TextEditingController _purchaseValueController;
  late final TextEditingController _appRatingController;
  late final TextEditingController _suggestionController;
  late final TextEditingController _expiryMonthsController;
  late final TextEditingController _minRedemptionController;
  bool _initialized = false;

  void _initFrom(rules) {
    if (_initialized) return;
    _purchaseValueController = TextEditingController(text: rules.purchaseValue.toString());
    _appRatingController = TextEditingController(text: rules.appRatingPoints.toString());
    _suggestionController = TextEditingController(text: rules.suggestionPoints.toString());
    _expiryMonthsController = TextEditingController(text: rules.expiryMonths.toString());
    _minRedemptionController = TextEditingController(text: rules.minRedemption.toString());
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _purchaseValueController.dispose();
      _appRatingController.dispose();
      _suggestionController.dispose();
      _expiryMonthsController.dispose();
      _minRedemptionController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoyaltyRulesCubit, LoyaltyRulesState>(
      builder: (context, state) {
        if (state.status == LoyaltyRulesStatus.loading || state.status == LoyaltyRulesStatus.initial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == LoyaltyRulesStatus.error) {
          return Center(child: Text(state.errorMessage ?? AdminStrings.somethingWentWrong));
        }

        _initFrom(state.rules);
        final cubit = context.read<LoyaltyRulesCubit>();
        final rules = state.rules;

        void save() {
          cubit.update(rules.copyWith(
            purchaseValue: double.tryParse(_purchaseValueController.text.trim()) ?? rules.purchaseValue,
            appRatingPoints: int.tryParse(_appRatingController.text.trim()) ?? rules.appRatingPoints,
            suggestionPoints: int.tryParse(_suggestionController.text.trim()) ?? rules.suggestionPoints,
            expiryMonths: int.tryParse(_expiryMonthsController.text.trim()) ?? rules.expiryMonths,
            minRedemption: int.tryParse(_minRedemptionController.text.trim()) ?? rules.minRedemption,
          ));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminCard(
              title: AdminStrings.pointsPerPurchase,
              actions: [
                Switch(
                  value: rules.purchaseRuleEnabled,
                  activeColor: AdminColors.gold,
                  onChanged: (v) => cubit.update(rules.copyWith(purchaseRuleEnabled: v)),
                ),
              ],
              child: Opacity(
                opacity: rules.purchaseRuleEnabled ? 1 : 0.4,
                child: IgnorePointer(
                  ignoring: !rules.purchaseRuleEnabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AdminField(
                        label: AdminStrings.purchasePointsType,
                        child: AdminOptionChips<bool>(
                          options: const [false, true],
                          selected: rules.purchaseIsPercentage,
                          allowNone: false,
                          labelOf: (v) => v ? AdminStrings.pointsPercentage : AdminStrings.pointsFixed,
                          onChanged: (v) => cubit.update(rules.copyWith(purchaseIsPercentage: v)),
                        ),
                      ),
                      AdminField(
                        label: rules.purchaseIsPercentage ? AdminStrings.pointsPercentage : AdminStrings.pointsFixed,
                        child: AdminTextInput(
                          controller: _purchaseValueController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => save(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminCard(
              title: AdminStrings.appRatingPoints,
              actions: [
                Switch(
                  value: rules.appRatingRuleEnabled,
                  activeColor: AdminColors.gold,
                  onChanged: (v) => cubit.update(rules.copyWith(appRatingRuleEnabled: v)),
                ),
              ],
              child: Opacity(
                opacity: rules.appRatingRuleEnabled ? 1 : 0.4,
                child: IgnorePointer(
                  ignoring: !rules.appRatingRuleEnabled,
                  child: AdminTextInput(
                    controller: _appRatingController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => save(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminCard(
              title: AdminStrings.suggestionPoints,
              actions: [
                Switch(
                  value: rules.suggestionRuleEnabled,
                  activeColor: AdminColors.gold,
                  onChanged: (v) => cubit.update(rules.copyWith(suggestionRuleEnabled: v)),
                ),
              ],
              child: Opacity(
                opacity: rules.suggestionRuleEnabled ? 1 : 0.4,
                child: IgnorePointer(
                  ignoring: !rules.suggestionRuleEnabled,
                  child: AdminTextInput(
                    controller: _suggestionController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => save(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminCard(
              title: AdminStrings.pointsExpiry,
              actions: [
                Switch(
                  value: rules.expiryEnabled,
                  activeColor: AdminColors.gold,
                  onChanged: (v) => cubit.update(rules.copyWith(expiryEnabled: v)),
                ),
              ],
              child: rules.expiryEnabled
                  ? AdminField(
                label: AdminStrings.expiryMonths,
                child: AdminTextInput(
                  controller: _expiryMonthsController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => save(),
                ),
              )
                  : Text(AdminStrings.noExpiry, style: AdminTextStyles.caption),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminCard(
              title: AdminStrings.minRedemption,
              child: AdminTextInput(
                controller: _minRedemptionController,
                keyboardType: TextInputType.number,
                onChanged: (_) => save(),
              ),
            ),
          ],
        );
      },
    );
  }
}