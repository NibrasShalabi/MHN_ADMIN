import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/broadcast.dart';

/// Messages to every customer. The client app reads the latest 50, so the
/// admin list shows the same window.
class BroadcastsRepository {
  static const int limit = 50;

  final FirebaseFirestore _db;

  BroadcastsRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _messages => _db.collection('admin_messages');

  Future<List<Broadcast>> recent() async {
    final snap = await _messages
        .where('type', isEqualTo: 'broadcast')
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .get();
    return [
      for (final d in snap.docs)
        Broadcast(
          id: d.id,
          title: d.data()['title'] as String? ?? '',
          body: d.data()['body'] as String? ?? '',
          sentAt: (d.data()['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ),
    ];
  }

  Future<void> send({required String title, required String body}) => _messages.add({
        'type': 'broadcast',
        'title': title.trim(),
        'body': body.trim(),
        'sentAt': FieldValue.serverTimestamp(),
      });

  Future<void> delete(String id) => _messages.doc(id).delete();
}
