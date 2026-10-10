import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../messages/data/repository/customer_messages.dart';
import '../../../messages/domain/entities/message_event.dart';
import '../../domain/entities/support_message.dart';
import 'support_repository.dart';

class FirebaseAdminSupportRepository implements SupportRepository {
  static const int _pageSize = 50;
  static const int _whereInLimit = 30;

  final FirebaseFirestore _db;
  final CustomerMessages _messages;

  FirebaseAdminSupportRepository(this._db, this._messages);

  @override
  Future<List<SupportMessage>> getMessages() async {
    final snap = await _db
        .collection('support_messages')
        .orderBy('sentAt', descending: true)
        .limit(_pageSize)
        .get();

    final messages = snap.docs.map(_fromDoc).toList();
    final names = await _namesFor(messages.where((m) => m.sentBy.isEmpty).map((m) => m.userId).toSet());

    return [
      for (final m in messages) m.sentBy.isEmpty ? m.copyWith(sentBy: names[m.userId] ?? m.userId) : m,
    ];
  }

  @override
  Future<void> resolve(SupportMessage message, {String? reply}) async {
    final batch = _db.batch()
      ..update(_db.collection('support_messages').doc(message.id), {
        'isRead': true,
        'status': 'resolved',
        if (reply != null) 'reply': reply,
      });

    if (reply != null) {
      await _messages.templates();
      // A typed reply always reaches the customer, even with the template off.
      final sent = _messages.compose(MessageEvent.supportReply,
          userId: message.userId, linkId: message.id, values: {MessageVar.reply: reply}, force: true);
      if (sent != null) batch.set(sent.ref, sent.data);
    }

    await batch.commit();
  }

  /// Fallback for tickets sent before userName was stored — one read per
  /// 30 users instead of one per ticket.
  Future<Map<String, String>> _namesFor(Set<String> userIds) async {
    final ids = userIds.where((id) => id.isNotEmpty).toList();
    final names = <String, String>{};

    for (var i = 0; i < ids.length; i += _whereInLimit) {
      final chunk = ids.sublist(i, (i + _whereInLimit).clamp(0, ids.length));
      final snap = await _db.collection('users').where(FieldPath.documentId, whereIn: chunk).get();
      for (final doc in snap.docs) {
        final d = doc.data();
        final name = '${d['fullName'] ?? ''} ${d['familyName'] ?? ''}'.trim();
        if (name.isNotEmpty) names[doc.id] = name;
      }
    }
    return names;
  }

  SupportMessage _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return SupportMessage(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      sentBy: d['userName'] as String? ?? '',
      topic: _mapTopic(d['topic'] as String?),
      body: d['body'] as String? ?? '',
      status: d['status'] == 'resolved' ? SupportStatus.resolved : SupportStatus.open,
      createdAt: (d['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reply: d['reply'] as String?,
    );
  }

  SupportTopic _mapTopic(String? value) => switch (value) {
    'complaint' => SupportTopic.complaint,
    'suggestion' => SupportTopic.suggestion,
    'bug' => SupportTopic.bug,
    _ => SupportTopic.other,
  };
}