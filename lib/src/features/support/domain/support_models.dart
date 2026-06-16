enum SupportTicketStatus {
  open,
  waitingForAdmin,
  waitingForMember,
  closed;

  String get label {
    return switch (this) {
      SupportTicketStatus.open => 'Open',
      SupportTicketStatus.waitingForAdmin => 'Waiting for admin',
      SupportTicketStatus.waitingForMember => 'Waiting for member',
      SupportTicketStatus.closed => 'Closed',
    };
  }
}

enum SupportMessageSender { member, admin }

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.uid,
    required this.subject,
    required this.status,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.userEmail,
    this.userDisplayName,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      userEmail: json['userEmail'] as String?,
      userDisplayName: json['userDisplayName'] as String?,
      status: _statusFromString(json['status'] as String?),
      messages: _messages(json['messages']),
      createdAt: _dateTime(json['createdAt']),
      updatedAt: _dateTime(json['updatedAt']),
    );
  }

  final String id;
  final String uid;
  final String subject;
  final String? userEmail;
  final String? userDisplayName;
  final SupportTicketStatus status;
  final List<SupportMessage> messages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupportMessage? get latestMessage => messages.isEmpty ? null : messages.last;

  bool get isClosed => status == SupportTicketStatus.closed;
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] as String? ?? '',
      sender: _senderFromString(json['senderRole'] as String?),
      body: json['body'] as String? ?? '',
      createdAt: _dateTime(json['createdAt']),
    );
  }

  final String id;
  final SupportMessageSender sender;
  final String body;
  final DateTime? createdAt;

  bool get isAdmin => sender == SupportMessageSender.admin;
}

SupportTicketStatus _statusFromString(String? value) {
  return switch (value) {
    'waiting_for_admin' => SupportTicketStatus.waitingForAdmin,
    'waiting_for_member' => SupportTicketStatus.waitingForMember,
    'closed' => SupportTicketStatus.closed,
    _ => SupportTicketStatus.open,
  };
}

SupportMessageSender _senderFromString(String? value) {
  return value == 'admin'
      ? SupportMessageSender.admin
      : SupportMessageSender.member;
}

List<SupportMessage> _messages(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => SupportMessage.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

DateTime? _dateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
