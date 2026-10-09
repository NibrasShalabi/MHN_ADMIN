import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/constants/syrian_governorates.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../data/repository/shipping_repository.dart';
import '../../domain/entities/shipping_rates.dart';
import '../cubits/shipping_cubit.dart';

class ShippingPage extends StatelessWidget {
  const ShippingPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ShippingCubit(GetIt.instance<ShippingRepository>())..load(),
        child: BlocConsumer<ShippingCubit, ShippingState>(
          listenWhen: (_, s) => s.status == ShippingStatus.saved || s.error != null,
          listener: (context, s) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.error ?? AdminStrings.saved)),
          ),
          buildWhen: (prev, s) => prev.status == ShippingStatus.loading || s.status == ShippingStatus.error,
          builder: (context, s) => switch (s.status) {
            ShippingStatus.loading => const Center(child: CircularProgressIndicator()),
            ShippingStatus.error => Center(child: Text(s.error ?? AdminStrings.somethingWentWrong)),
            _ => _ShippingForm(initial: s.rates),
          },
        ),
      );
}

class _ShippingForm extends StatefulWidget {
  final ShippingRates initial;

  const _ShippingForm({required this.initial});

  @override
  State<_ShippingForm> createState() => _ShippingFormState();
}

class _ShippingFormState extends State<_ShippingForm> {
  late final Map<String, TextEditingController> _fees = {
    for (final g in SyrianGovernorates.all)
      g: TextEditingController(text: widget.initial.fees[g]?.toStringAsFixed(0) ?? ''),
  };
  late final _freeAbove = TextEditingController(
    text: widget.initial.freeAbove > 0 ? widget.initial.freeAbove.toStringAsFixed(0) : '',
  );
  late bool _freeEnabled = widget.initial.freeEnabled;

  @override
  void dispose() {
    for (final c in _fees.values) {
      c.dispose();
    }
    _freeAbove.dispose();
    super.dispose();
  }

  ShippingRates get _rates => ShippingRates(
        fees: {for (final e in _fees.entries) e.key: double.tryParse(e.value.text.trim()) ?? 0},
        freeEnabled: _freeEnabled,
        freeAbove: double.tryParse(_freeAbove.text.trim()) ?? 0,
      );

  @override
  Widget build(BuildContext context) {
    final saving = context.select((ShippingCubit c) => c.state.status == ShippingStatus.saving);

    // The section body already scrolls — a second scroll view here broke the layout.
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminCard(
            title: AdminStrings.deliveryFees,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AdminStrings.deliveryFeesHint, style: AdminTextStyles.caption),
                const SizedBox(height: AdminConstants.spacingMd),
                Wrap(
                  spacing: AdminConstants.spacingMd,
                  runSpacing: AdminConstants.spacingSm,
                  children: [
                    for (final e in _fees.entries)
                      SizedBox(
                        width: 220,
                        child: AdminField(
                          label: e.key,
                          child: AdminTextInput(controller: e.value, keyboardType: TextInputType.number, hint: '0'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminConstants.spacingLg),
          AdminCard(
            title: AdminStrings.freeDelivery,
            actions: [
              Switch(
                value: _freeEnabled,
                activeThumbColor: AdminColors.gold,
                onChanged: (v) => setState(() => _freeEnabled = v),
              ),
            ],
            child: AdminField(
              label: AdminStrings.freeDeliveryAbove,
              hint: AdminStrings.freeDeliveryHint,
              child: AdminTextInput(controller: _freeAbove, keyboardType: TextInputType.number),
            ),
          ),
          const SizedBox(height: AdminConstants.spacingLg),
          AdminButton(
            label: AdminStrings.save,
            onPressed: saving ? null : () => context.read<ShippingCubit>().save(_rates),
          ),
        ],
    );
  }
}
