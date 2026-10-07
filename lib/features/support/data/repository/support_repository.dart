import '../../domain/entities/support_message.dart';

abstract class SupportRepository {
  Future<List<SupportMessage>> getMessages();

  /// Resolves the ticket and, when there's a reply, notifies the user
  /// through admin_messages — atomically.
  Future<void> resolve(SupportMessage message, {String? reply});
}