import '../../domain/entities/support_message.dart';
import 'support_repository.dart';

class FakeSupportRepository implements SupportRepository {
  final List<SupportMessage> _messages = [
    SupportMessage(
      id: 'SUP-1',
      sentBy: 'محمد العلي',
      topic: SupportTopic.complaint,
      body: 'وصلني الطلب متأخر عن الموعد بيوم كامل.',
      status: SupportStatus.open,
      createdAt: DateTime(2026, 8, 24),
    ),
  ];

  @override
  Future<List<SupportMessage>> getMessages() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_messages);
  }

  @override
  Future<void> markResolved(String id, {String? reply}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: SupportStatus.resolved, reply: reply);
    }
  }
}