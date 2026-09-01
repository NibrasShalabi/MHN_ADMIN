import '../../domain/entities/support_message.dart';

abstract class SupportRepository {
  Future<List<SupportMessage>> getMessages();
  Future<void> markResolved(String id, {String? reply});
}