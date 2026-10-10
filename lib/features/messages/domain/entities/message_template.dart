import 'package:equatable/equatable.dart';

import 'message_event.dart';

class MessageTemplate extends Equatable {
  final String title;
  final String body;
  final bool enabled;

  const MessageTemplate({required this.title, required this.body, this.enabled = true});

  factory MessageTemplate.defaultOf(MessageEvent e) => MessageTemplate(title: e.defaultTitle, body: e.defaultBody);

  factory MessageTemplate.fromMap(MessageEvent e, Map<String, dynamic>? m) => MessageTemplate(
        title: (m?['title'] as String?)?.trim().isNotEmpty == true ? m!['title'] as String : e.defaultTitle,
        body: (m?['body'] as String?)?.trim().isNotEmpty == true ? m!['body'] as String : e.defaultBody,
        enabled: m?['enabled'] as bool? ?? true,
      );

  Map<String, dynamic> toMap() => {'title': title, 'body': body, 'enabled': enabled};

  MessageTemplate copyWith({String? title, String? body, bool? enabled}) =>
      MessageTemplate(title: title ?? this.title, body: body ?? this.body, enabled: enabled ?? this.enabled);

  /// Fills the placeholders. A line whose placeholder has no value is dropped,
  /// so "you earned {points} points" disappears when nothing was earned.
  ({String title, String body}) render(Map<MessageVar, String> values) {
    String fill(String text) => text
        .split('\n')
        .where((line) => !MessageVar.values.any((v) => line.contains(v.token) && (values[v] ?? '').trim().isEmpty))
        .map((line) => values.entries.fold(line, (s, e) => s.replaceAll(e.key.token, e.value.trim())))
        .join('\n')
        .trim();
    return (title: fill(title), body: fill(body));
  }

  @override
  List<Object?> get props => [title, body, enabled];
}

/// All templates, stored as one document so they load in a single read.
class MessageTemplates {
  final Map<MessageEvent, MessageTemplate> _byEvent;

  MessageTemplates(this._byEvent);

  factory MessageTemplates.fromMap(Map<String, dynamic>? map) => MessageTemplates({
        for (final e in MessageEvent.values) e: MessageTemplate.fromMap(e, map?[e.key] as Map<String, dynamic>?),
      });

  MessageTemplate of(MessageEvent e) => _byEvent[e] ?? MessageTemplate.defaultOf(e);

  MessageTemplates replace(MessageEvent e, MessageTemplate t) => MessageTemplates({..._byEvent, e: t});

  Map<String, dynamic> toMap() => {for (final e in MessageEvent.values) e.key: of(e).toMap()};
}
