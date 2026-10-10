import 'package:flutter/material.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_chips.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../domain/entities/message_event.dart';
import '../../domain/entities/message_template.dart';
import 'message_preview.dart';

/// One automatic message: on/off, title, body, placeholder chips that insert
/// at the cursor, and a live preview with sample values.
class TemplateEditor extends StatefulWidget {
  final MessageEvent event;
  final MessageTemplate template;
  final ValueChanged<MessageTemplate> onChanged;

  const TemplateEditor({super.key, required this.event, required this.template, required this.onChanged});

  static const Map<MessageVar, String> _samples = {
    MessageVar.orderId: 'MHN-1024',
    MessageVar.points: '150',
    MessageVar.reason: 'المبلغ المحوَّل ناقص',
    MessageVar.product: 'سماعة بلوتوث',
    MessageVar.note: 'ملاحظة من الأدمن',
    MessageVar.reply: 'أهلاً، تم حل المشكلة.',
  };

  @override
  State<TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends State<TemplateEditor> {
  late final _title = TextEditingController(text: widget.template.title);
  late final _body = TextEditingController(text: widget.template.body);
  late TextEditingController _focused = _body;

  @override
  void didUpdateWidget(TemplateEditor old) {
    super.didUpdateWidget(old);
    // Reset to default replaces the template from outside.
    if (widget.template.title != _title.text) _title.text = widget.template.title;
    if (widget.template.body != _body.text) _body.text = widget.template.body;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged(widget.template.copyWith(title: _title.text, body: _body.text));

  void _insert(MessageVar v) {
    final c = _focused;
    final sel = c.selection.isValid ? c.selection : TextSelection.collapsed(offset: c.text.length);
    c.value = TextEditingValue(
      text: c.text.replaceRange(sel.start, sel.end, v.token),
      selection: TextSelection.collapsed(offset: sel.start + v.token.length),
    );
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event, t = widget.template;
    final missing = event.requiredVar;
    final preview = t.render(TemplateEditor._samples);

    return AdminCard(
      title: event.label,
      actions: [
        Text(t.enabled ? AdminStrings.templateOn : AdminStrings.templateOff, style: AdminTextStyles.caption),
        Switch(
          value: t.enabled,
          activeThumbColor: AdminColors.gold,
          onChanged: (on) => widget.onChanged(t.copyWith(enabled: on)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminField(
            label: AdminStrings.templateTitleLabel,
            child: Focus(
              onFocusChange: (f) => f ? _focused = _title : null,
              child: AdminTextInput(controller: _title, onChanged: (_) => _emit()),
            ),
          ),
          AdminField(
            label: AdminStrings.templateBodyLabel,
            child: Focus(
              onFocusChange: (f) => f ? _focused = _body : null,
              child: AdminTextInput(
                controller: _body,
                maxLines: 4,
                onChanged: (_) => _emit(),
                errorText: missing != null && !t.body.contains(missing.token)
                    ? AdminStrings.templateMissingVar(missing.token)
                    : null,
              ),
            ),
          ),
          Wrap(
            spacing: AdminConstants.spacingSm,
            runSpacing: AdminConstants.spacingSm,
            children: [
              for (final v in event.vars)
                AdminChip(label: '${v.label}  ${v.token}', isSelected: false, onTap: () => _insert(v)),
            ],
          ),
          const SizedBox(height: AdminConstants.spacingMd),
          Text(AdminStrings.templatePreview, style: AdminTextStyles.label),
          const SizedBox(height: AdminConstants.spacingSm),
          MessagePreview(title: preview.title, body: preview.body),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => widget.onChanged(MessageTemplate.defaultOf(event).copyWith(enabled: t.enabled)),
              icon: const Icon(Icons.restart_alt, size: 18, color: AdminColors.gold),
              label: Text(AdminStrings.templateReset, style: AdminTextStyles.caption.copyWith(color: AdminColors.gold)),
            ),
          ),
        ],
      ),
    );
  }
}
