import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/injector/injector.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../data/repository/customer_messages.dart';
import '../../domain/entities/message_event.dart';
import '../../domain/entities/message_template.dart';
import '../widgets/broadcasts_section.dart';
import '../widgets/template_editor.dart';

/// Everything the customer reads in their inbox: broadcasts and the
/// automatic messages behind every order, payment, suggestion and reply.
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _service = getIt<CustomerMessages>();
  MessageTemplates? _saved;
  MessageTemplates? _draft;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final t = await _service.templates(refresh: true);
      if (mounted) setState(() => _saved = _draft = t);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  bool get _dirty => _draft != null && _saved != null && !_same(_draft!, _saved!);

  bool get _valid => MessageEvent.values.every(
        (e) => e.requiredVar == null || _draft!.of(e).body.contains(e.requiredVar!.token),
      );

  static bool _same(MessageTemplates a, MessageTemplates b) => MessageEvent.values.every((e) => a.of(e) == b.of(e));

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.saveTemplates(_draft!);
      _saved = _draft;
      _toast(AdminStrings.saved);
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
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
        const BroadcastsSection(),
        const SizedBox(height: AdminConstants.spacingXl),
        Text(AdminStrings.templatesTitle, style: AdminTextStyles.pageTitle),
        const SizedBox(height: AdminConstants.spacingXs),
        Text(AdminStrings.templatesHint, style: AdminTextStyles.caption),
        const SizedBox(height: AdminConstants.spacingLg),
        if (_error != null)
          Text(_error!, style: AdminTextStyles.caption)
        else if (_draft == null)
          const Center(child: CircularProgressIndicator())
        else ...[
          for (final e in MessageEvent.values) ...[
            TemplateEditor(
              event: e,
              template: _draft!.of(e),
              onChanged: (t) => setState(() => _draft = _draft!.replace(e, t)),
            ),
            const SizedBox(height: AdminConstants.spacingMd),
          ],
          AdminButton(label: AdminStrings.save, onPressed: _saving || !_dirty || !_valid ? null : _save),
        ],
      ],
    );
  }
}
