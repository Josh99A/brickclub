import 'support_models.dart';

abstract interface class SupportRepository {
  Stream<List<SupportTicket>> watchMyTickets();

  Future<void> createTicket({required String subject, required String message});

  Future<void> replyToTicket({
    required String ticketId,
    required String message,
  });
}
