import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../data/repository/payment_settings_repository.dart';
import '../../domain/entities/payment_settings.dart';

/// Wallet addresses and the Sham Cash number customers pay to, plus an
/// on/off switch per method. Saving asks for confirmation — a wrong
/// character here sends real money to the wrong place.
class PaymentSettingsPage extends StatefulWidget {
  const PaymentSettingsPage({super.key});

  @override
  State<PaymentSettingsPage> createState() => _PaymentSettingsPageState();
}

class _PaymentSettingsPageState extends State<PaymentSettingsPage> {
  final _repo = GetIt.instance<PaymentSettingsRepository>();
  final _fields = {for (final c in PaymentChannel.values) c: TextEditingController()};
  final _disabled = <PaymentChannel>{};
  PaymentSettings _saved = const PaymentSettings();
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final s = await _repo.get();
      if (!mounted) return;
      setState(() {
        _saved = s;
        for (final e in _fields.entries) {
          e.value.text = s.addresses[e.key] ?? '';
        }
        _disabled
          ..clear()
          ..addAll(s.disabled);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  String _value(PaymentChannel c) => _fields[c]!.text.trim();

  String? _errorFor(PaymentChannel c) {
    final v = _value(c);
    return v.isEmpty || c.isValidAddress(v) ? null : AdminStrings.invalidAddress;
  }

  PaymentSettings get _current => PaymentSettings(
        addresses: {for (final c in PaymentChannel.values) if (_value(c).isNotEmpty) c: _value(c)},
        disabled: {..._disabled},
      );

  Future<void> _save() async {
    if (PaymentChannel.values.any((c) => _errorFor(c) != null)) return;
    final next = _current;
    final changed = [
      for (final c in PaymentChannel.values)
        if (next.addresses[c] != _saved.addresses[c]) c,
    ];
    if (changed.isNotEmpty && !await _confirm(changed, next)) return;

    setState(() => _saving = true);
    try {
      await _repo.save(next);
      _saved = next;
      _toast(AdminStrings.saved);
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _confirm(List<PaymentChannel> changed, PaymentSettings next) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AdminColors.surface,
          title: Text(AdminStrings.confirmAddresses, style: AdminTextStyles.sectionTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AdminStrings.confirmAddressesHint, style: AdminTextStyles.caption),
              const SizedBox(height: AdminConstants.spacingMd),
              for (final c in changed) ...[
                Text(c.label, style: AdminTextStyles.label),
                SelectableText(
                  next.addresses[c] ?? AdminStrings.addressRemoved,
                  style: AdminTextStyles.body.copyWith(color: AdminColors.gold, fontFamily: 'monospace'),
                ),
                const SizedBox(height: AdminConstants.spacingSm),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AdminStrings.cancel)),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AdminStrings.confirm)),
          ],
        ),
      ) ??
      false;

  void _toast(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_loadError != null) return Center(child: Text(_loadError!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AdminStrings.paymentAddressesHint, style: AdminTextStyles.caption),
        const SizedBox(height: AdminConstants.spacingLg),
        for (final c in PaymentChannel.values) ...[
          AdminCard(
            title: c.label,
            actions: [
              Text(
                _disabled.contains(c) ? AdminStrings.methodOff : AdminStrings.methodOn,
                style: AdminTextStyles.caption,
              ),
              Switch(
                value: !_disabled.contains(c),
                activeThumbColor: AdminColors.gold,
                onChanged: (on) => setState(() => on ? _disabled.remove(c) : _disabled.add(c)),
              ),
            ],
            child: AdminTextInput(
              controller: _fields[c]!,
              hint: c == PaymentChannel.shamCash ? AdminStrings.shamCashHint : AdminStrings.walletHint,
              errorText: _errorFor(c),
              onChanged: (_) => setState(() {}),
              suffixIcon: IconButton(
                icon: const Icon(Icons.copy, size: 18, color: AdminColors.gold),
                tooltip: AdminStrings.copy,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _value(c)));
                  _toast(AdminStrings.copied);
                },
              ),
            ),
          ),
          const SizedBox(height: AdminConstants.spacingMd),
        ],
        const SizedBox(height: AdminConstants.spacingSm),
        AdminButton(label: AdminStrings.save, onPressed: _saving ? null : _save),
      ],
    );
  }
}
