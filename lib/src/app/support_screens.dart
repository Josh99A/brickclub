part of 'brickclub_app.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key, required this.repository});

  final SupportRepository repository;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, 'Support'),
        body: StreamBuilder<List<SupportTicket>>(
          stream: repository.watchMyTickets(),
          builder: (context, snapshot) {
            final tickets = snapshot.data ?? const <SupportTicket>[];
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
              children: [
                PrimaryButton(
                  key: const ValueKey('new-support-ticket'),
                  label: 'New support request',
                  onPressed: () => _showCreateTicket(context),
                ),
                SizedBox(height: 18),
                if (snapshot.connectionState == ConnectionState.waiting)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  )
                else if (tickets.isEmpty)
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No support requests yet', style: AppText.h2),
                        SizedBox(height: 8),
                        Text(
                          'Start a conversation with the BrickClub team when you need account, KYC, wallet, or investment help.',
                          style: AppText.body,
                        ),
                      ],
                    ),
                  )
                else
                  for (final ticket in tickets)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SupportTicketTile(
                        ticket: ticket,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SupportThreadScreen(
                              repository: repository,
                              ticket: ticket,
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCreateTicket(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SupportComposerSheet(
        title: 'New support request',
        subjectEnabled: true,
        submitLabel: 'Send request',
        onSubmit: (subject, message) async {
          await repository.createTicket(subject: subject, message: message);
        },
      ),
    );
  }
}

class SupportThreadScreen extends StatelessWidget {
  const SupportThreadScreen({
    super.key,
    required this.repository,
    required this.ticket,
  });

  final SupportRepository repository;
  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, ticket.subject),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(ticket.status.label, style: AppText.goldBody),
                ),
                Text('${ticket.messages.length} messages', style: AppText.tiny),
              ],
            ),
            SizedBox(height: 16),
            for (final message in ticket.messages)
              _SupportMessageBubble(message: message),
            SizedBox(height: 16),
            PrimaryButton(
              key: const ValueKey('reply-support-ticket'),
              label: ticket.isClosed ? 'Request closed' : 'Reply',
              onPressed: ticket.isClosed ? null : () => _showReply(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReply(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SupportComposerSheet(
        title: 'Reply to support',
        subjectEnabled: false,
        submitLabel: 'Send reply',
        onSubmit: (_, message) async {
          await repository.replyToTicket(ticketId: ticket.id, message: message);
        },
      ),
    );
  }
}

class _SupportTicketTile extends StatelessWidget {
  const _SupportTicketTile({required this.ticket, required this.onTap});

  final SupportTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(ticket.subject, style: AppText.h2)),
                  Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                ],
              ),
              SizedBox(height: 8),
              Text(
                ticket.latestMessage?.body ?? 'No messages yet',
                style: AppText.body,
              ),
              SizedBox(height: 12),
              ChoicePill(label: ticket.status.label, selected: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportMessageBubble extends StatelessWidget {
  const _SupportMessageBubble({required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment = message.isAdmin
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;
    final color = message.isAdmin ? AppColors.panel : AppColors.goldSoft;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            message.isAdmin ? 'BrickClub support' : 'You',
            style: AppText.tinyLight,
          ),
          SizedBox(height: 5),
          Container(
            constraints: const BoxConstraints(maxWidth: 290),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(message.body, style: AppText.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _SupportComposerSheet extends StatefulWidget {
  const _SupportComposerSheet({
    required this.title,
    required this.subjectEnabled,
    required this.submitLabel,
    required this.onSubmit,
  });

  final String title;
  final bool subjectEnabled;
  final String submitLabel;
  final Future<void> Function(String subject, String message) onSubmit;

  @override
  State<_SupportComposerSheet> createState() => _SupportComposerSheetState();
}

class _SupportComposerSheetState extends State<_SupportComposerSheet> {
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  bool submitting = false;

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        22,
        22,
        MediaQuery.viewInsetsOf(context).bottom + 26,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: AppText.h2),
          if (widget.subjectEnabled) ...[
            SizedBox(height: 16),
            const FieldLabel('Subject'),
            SizedBox(height: 8),
            AppTextField(
              key: const ValueKey('support-subject'),
              controller: subjectController,
              hintText: 'What do you need help with?',
              prefixIcon: Icons.support_agent_rounded,
            ),
          ],
          SizedBox(height: 16),
          const FieldLabel('Message'),
          SizedBox(height: 8),
          TextField(
            key: const ValueKey('support-message'),
            controller: messageController,
            minLines: 4,
            maxLines: 6,
            style: TextStyle(fontSize: 14, color: AppColors.primary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              hintText: 'Type your message',
              hintStyle: AppText.placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.gold, width: 1.3),
              ),
            ),
          ),
          SizedBox(height: 18),
          PrimaryButton(
            key: const ValueKey('send-support-message'),
            label: submitting ? 'Sending...' : widget.submitLabel,
            onPressed: submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final subject = subjectController.text.trim();
    final message = messageController.text.trim();
    if (widget.subjectEnabled && subject.isEmpty) {
      showMessage(context, 'Enter a subject');
      return;
    }
    if (message.isEmpty) {
      showMessage(context, 'Enter a message');
      return;
    }

    setState(() => submitting = true);
    try {
      await widget.onSubmit(subject, message);
      if (mounted) {
        Navigator.pop(context);
        showMessage(context, 'Message sent');
      }
    } catch (error) {
      if (mounted) showMessage(context, _friendlyUnexpectedMessage(error));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }
}

