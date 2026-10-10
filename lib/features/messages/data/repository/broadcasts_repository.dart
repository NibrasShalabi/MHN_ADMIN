import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/broadcast.dart';

/// Messages to every customer. A customer sees the ones sent after she
/// joined, plus those marked [Broadcast.forNewCustomers].
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
          forNewCustomers: d.data()['forNewCustomers'] == true,
        ),
    ];
  }

  Future<void> send({required String title, required String body, bool forNewCustomers = false}) =>
      _messages.add({
        'type': 'broadcast',
        'title': title.trim(),
        'body': body.trim(),
        'sentAt': FieldValue.serverTimestamp(),
        'forNewCustomers': forNewCustomers,
      });

  Future<void> setForNewCustomers(String id, bool on) => _messages.doc(id).update({'forNewCustomers': on});

  Future<void> delete(String id) => _messages.doc(id).delete();
}
