import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/injector/injector.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_confirm_dialog.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../data/repository/broadcasts_repository.dart';
import '../../domain/entities/broadcast.dart';
import 'message_preview.dart';
import '../../../../core/error/admin_error.dart';

/// Compose a message for every customer, and see / remove what was sent.
class BroadcastsSection extends StatefulWidget {
  const BroadcastsSection({super.key});

  @override
  State<BroadcastsSection> createState() => _BroadcastsSectionState();
}

class _BroadcastsSectionState extends State<BroadcastsSection> {
  static final DateFormat _date = DateFormat('yyyy/MM/dd · HH:mm', 'ar');

  final _repo = getIt<BroadcastsRepository>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  late Future<List<Broadcast>> _sent = _repo.recent();
  bool _sending = false;
  bool _forNew = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _title.text.trim(), body = _body.text.trim();
    final ok = await showAdminConfirm(
      context,
      title: AdminStrings.broadcastConfirm,
      message: AdminStrings.broadcastConfirmHint,
      content: MessagePreview(title: title, body: body),
    );
    if (!ok) return;
    await _run(() => _repo.send(title: title, body: body, forNewCustomers: _forNew), AdminStrings.broadcastSent, onDone: () {
      _title.clear();
      _body.clear();
      _forNew = false;
    });
  }

  Future<void> _delete(Broadcast b) async {
    if (!await showAdminConfirm(context, title: AdminStrings.delete, message: AdminStrings.broadcastDeleteConfirm)) return;
    await _run(() => _repo.delete(b.id), AdminStrings.deleted);
  }

  Future<void> _run(Future<void> Function() action, String done, {VoidCallback? onDone}) async {
    setState(() => _sending = true);
    try {
      await action();
      onDone?.call();
      _sent = _repo.recent();
      _toast(done);
    } catch (e) {
      _toast(AdminError.message(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _toast(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminCard(
          title: AdminStrings.broadcastTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AdminStrings.broadcastHint, style: AdminTextStyles.caption),
              const SizedBox(height: AdminConstants.spacingMd),
              AdminTextInput(controller: _title, hint: AdminStrings.broadcastTitleHint, onChanged: (_) => setState(() {})),
              const SizedBox(height: AdminConstants.spacingSm),
              AdminTextInput(controller: _body, hint: AdminStrings.broadcastBodyHint, maxLines: 4, onChanged: (_) => setState(() {})),
              _ForNewSwitch(value: _forNew, onChanged: (v) => setState(() => _forNew = v)),
              const SizedBox(height: AdminConstants.spacingMd),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AdminButton(
                  label: AdminStrings.broadcastSend,
                  icon: Icons.send_outlined,
                  onPressed: _sending || _body.text.trim().isEmpty ? null : _send,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AdminConstants.spacingLg),
        AdminCard(
          title: AdminStrings.broadcastHistory,
          child: FutureBuilder<List<Broadcast>>(
            future: _sent,
            builder: (context, snap) {
              if (snap.hasError) return Text('${snap.error}', style: AdminTextStyles.caption);
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              if (snap.data!.isEmpty) return Text(AdminStrings.broadcastEmpty, style: AdminTextStyles.caption);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final b in snap.data!) ...[
                    Text(_date.format(b.sentAt), style: AdminTextStyles.caption),
                    const SizedBox(height: AdminConstants.spacingXs),
                    MessagePreview(
                      title: b.title,
                      body: b.body,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AdminColors.danger, size: 20),
                        tooltip: AdminStrings.delete,
                        onPressed: _sending ? null : () => _delete(b),
                      ),
                    ),
                    _ForNewSwitch(
                      value: b.forNewCustomers,
                      onChanged: _sending
                          ? null
                          : (v) => _run(() => _repo.setForNewCustomers(b.id, v), AdminStrings.saved),
                    ),
                    const SizedBox(height: AdminConstants.spacingMd),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// "Show to customers who join later" — for lasting notices like a welcome
/// or the return policy.
class _ForNewSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _ForNewSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(value: value, activeThumbColor: AdminColors.gold, onChanged: onChanged),
        const SizedBox(width: AdminConstants.spacingSm),
        Expanded(child: Text(AdminStrings.broadcastForNew, style: AdminTextStyles.caption)),
      ],
    );
  }
}
