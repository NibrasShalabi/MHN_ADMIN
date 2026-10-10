import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message_event.dart';
import '../../domain/entities/message_template.dart';

/// The single place a customer message is written. Templates are read once
/// per session (one document) and kept in memory, so sending costs no reads.
class CustomerMessages {
  final FirebaseFirestore _db;
  MessageTemplates? _cache;

  CustomerMessages(this._db);

  DocumentReference<Map<String, dynamic>> get _doc => _db.collection('config').doc('message_templates');
  CollectionReference<Map<String, dynamic>> get _messages => _db.collection('admin_messages');

  Future<MessageTemplates> templates({bool refresh = false}) async {
    if (!refresh && _cache != null) return _cache!;
    return _cache = MessageTemplates.fromMap((await _doc.get()).data());
  }

  Future<void> saveTemplates(MessageTemplates templates) async {
    await _doc.set(templates.toMap());
    _cache = templates;
  }

  /// The message document for [event], or null when the admin turned it off
  /// ([force] still sends it — the admin asked to notify with a note).
  /// Call [templates] first — this never reads, so it is safe inside a
  /// transaction after its writes started.
  ({DocumentReference<Map<String, dynamic>> ref, Map<String, dynamic> data})? compose(
    MessageEvent event, {
    required String userId,
    String? orderId,
    Map<MessageVar, String> values = const {},
    String? linkId,
    bool force = false,
  }) {
    final template = (_cache ?? MessageTemplates.fromMap(null)).of(event);
    if (!template.enabled && !force) return null;
    final text = template.render({if (orderId != null) MessageVar.orderId: orderId, ...values});
    return (
      ref: _messages.doc(),
      data: {
        'type': event.type,
        'event': event.key,
        'userId': userId,
        'orderId': ?orderId,
        'supportMessageId': ?linkId,
        'title': text.title,
        'body': text.body,
        'isRead': false,
        'sentAt': FieldValue.serverTimestamp(),
      },
    );
  }
}
