import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/support_message.dart';
import 'support_repository.dart';

class FirebaseAdminSupportRepository implements SupportRepository {
  final FirebaseFirestore _db;

  FirebaseAdminSupportRepository(this._db);

  @override
  @override
  Future<List<SupportMessage>> getMessages() async {
    final snap = await _db
        .collection('support_messages')
        .orderBy('sentAt', descending: true)
        .get();

    return Future.wait(snap.docs.map((doc) async {
      final d = doc.data();
      final userId = d['userId'] as String? ?? '';

      String userName = userId;
      try {
        final userDoc = await _db.collection('users').doc(userId).get();
        final fullName = userDoc.data()?['fullName'] as String?;
        final familyName = userDoc.data()?['familyName'] as String?;
        if (fullName != null) {
          userName = '$fullName ${familyName ?? ''}'.trim();
        }
      } catch (_) {}

      return SupportMessage(
        id: doc.id,
        sentBy: userName,
        topic: _mapTopic(d['topic'] as String?),
        body: d['body'] as String? ?? '',
        status: (d['status'] as String?) == 'resolved'
            ? SupportStatus.resolved
            : SupportStatus.open,
        createdAt: (d['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        reply: d['reply'] as String?,
      );
    }));
  }

  @override
  Future<void> markResolved(String id, {String? reply}) async {
    await _db.collection('support_messages').doc(id).update({
      'isRead': true,
      'status': 'resolved',
      if (reply != null) 'reply': reply,
    });
  }

  SupportMessage _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return SupportMessage(
      id: doc.id,
      sentBy: d['userId'] as String? ?? '',
      topic: _mapTopic(d['topic'] as String?),
      body: d['body'] as String? ?? '',
      status: (d['status'] as String?) == 'resolved'
          ? SupportStatus.resolved
          : SupportStatus.open,
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