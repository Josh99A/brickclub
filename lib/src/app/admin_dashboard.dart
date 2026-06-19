part of 'brickclub_app.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    required this.authRepository,
    required this.adminRepository,
    required this.onSignOut,
  });

  final AuthRepository authRepository;
  final AdminRepository adminRepository;
  final VoidCallback onSignOut;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  late Future<AdminDashboardData> dashboardFuture;

  static const sections = [
    ('Overview', Icons.grid_view_rounded),
    ('Users', Icons.people_alt_outlined),
    ('KYC', Icons.verified_user_outlined),
    ('Assets', Icons.apartment_outlined),
    ('Crypto payments', Icons.currency_bitcoin_rounded),
    ('Support', Icons.support_agent_rounded),
    ('Reports', Icons.bar_chart_rounded),
    ('Settings', Icons.settings_outlined),
  ];

  @override
  void initState() {
    super.initState();
    dashboardFuture = widget.adminRepository.loadDashboard();
  }

  void reloadDashboard() {
    setState(() {
      dashboardFuture = widget.adminRepository.loadDashboard();
    });
  }

  Future<void> _markNotificationsRead() async {
    await widget.adminRepository.markNotificationsRead();
    reloadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: wide ? null : Drawer(child: _sidebarContent()),
      body: Row(
        children: [
          if (wide) SizedBox(width: 252, child: _sidebarContent()),
          Expanded(
            child: ColoredBox(
              color: AppColors.surface,
              child: FutureBuilder<AdminDashboardData>(
                future: dashboardFuture,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  return Column(
                    children: [
                      _AdminTopBar(
                        title: sections[selectedIndex].$1,
                        showMenu: !wide,
                        user: widget.authRepository.currentUserDetails(),
                        notifications:
                            data?.notifications ?? const <AdminNotification>[],
                        onMarkNotificationsRead: _markNotificationsRead,
                      ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.gold,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return _AdminErrorState(
                                message: _adminErrorMessage(snapshot.error!),
                                onRetry: reloadDashboard,
                              );
                            }

                            return SingleChildScrollView(
                              padding: EdgeInsets.all(wide ? 30 : 18),
                              child: _AdminSection(
                                index: selectedIndex,
                                data: data!,
                                repository: widget.adminRepository,
                                onChanged: reloadDashboard,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarContent() {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _BrandLockup(),
                ),
              ),
              SizedBox(height: 46),
              for (var index = 0; index < sections.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _AdminNavItem(
                    key: ValueKey('admin-${sections[index].$1.toLowerCase()}'),
                    label: sections[index].$1,
                    icon: sections[index].$2,
                    selected: selectedIndex == index,
                    onTap: () {
                      setState(() => selectedIndex = index);
                      if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              const Spacer(),
              Divider(color: AppColors.border),
              SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: CircleAvatar(
                  backgroundColor: AppColors.panel,
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                title: Text(
                  widget.authRepository.currentUserDetails()?.primaryLabel ??
                      'Signed-in admin',
                  style: AppText.fieldLabel,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  widget.authRepository.currentUserDetails()?.email ??
                      'Admin access',
                  style: AppText.tinyLight,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _AdminNavItem(
                label: 'Sign out',
                icon: Icons.logout_rounded,
                selected: false,
                onTap: widget.onSignOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.goldSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.gold : AppColors.muted,
              ),
              SizedBox(width: 13),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.secondary,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({
    required this.title,
    required this.showMenu,
    required this.user,
    required this.notifications,
    required this.onMarkNotificationsRead,
  });

  final String title;
  final bool showMenu;
  final SignedInUserDetails? user;
  final List<AdminNotification> notifications;
  final Future<void> Function() onMarkNotificationsRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (showMenu) ...[
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.menu_rounded),
              ),
            ),
            SizedBox(width: 8),
          ],
          Text(
            title == 'Overview' ? 'Admin overview' : title,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (MediaQuery.sizeOf(context).width >= 720)
            SizedBox(
              width: 250,
              height: 42,
              child: TextField(
                style: AppText.fieldLabel,
                decoration: InputDecoration(
                  hintText: 'Search operations',
                  hintStyle: AppText.small,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.muted,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.panel,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gold),
                  ),
                ),
              ),
            ),
          SizedBox(width: 12),
          _NotificationsBell(
            notifications: notifications,
            onMarkRead: onMarkNotificationsRead,
          ),
          if (MediaQuery.sizeOf(context).width >= 900) ...[
            SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                user?.primaryLabel ?? 'Signed-in admin',
                style: AppText.fieldLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          SizedBox(width: 8),
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.panel,
            child: Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.gold,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsBell extends StatelessWidget {
  const _NotificationsBell({
    required this.notifications,
    required this.onMarkRead,
  });

  final List<AdminNotification> notifications;
  final Future<void> Function() onMarkRead;

  int get _unread =>
      notifications.where((notification) => notification.isUnread).length;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          key: const ValueKey('admin-notifications'),
          tooltip: 'Notifications',
          onPressed: () => _openSheet(context),
          icon: Icon(
            _unread > 0
                ? Icons.notifications_active_rounded
                : Icons.notifications_none_rounded,
          ),
        ),
        if (_unread > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 18),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                _unread > 9 ? '9+' : '$_unread',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0B0D0F),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _NotificationsSheet(
        notifications: notifications,
        onMarkRead: onMarkRead,
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({
    required this.notifications,
    required this.onMarkRead,
  });

  final List<AdminNotification> notifications;
  final Future<void> Function() onMarkRead;

  @override
  Widget build(BuildContext context) {
    final unread =
        notifications.where((notification) => notification.isUnread).length;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Notifications', style: AppText.h2)),
                if (unread > 0)
                  TextButton(
                    key: const ValueKey('mark-notifications-read'),
                    onPressed: () async {
                      Navigator.pop(context);
                      await onMarkRead();
                    },
                    child: Text('Mark all read', style: AppText.goldBody),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (notifications.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text("You're all caught up.", style: AppText.body),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: AppColors.border),
                  itemBuilder: (_, index) =>
                      _NotificationTile(notification: notifications[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AdminNotification notification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: notification.isUnread
                  ? AppColors.gold
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: AppText.fieldLabel),
                if (notification.body.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(notification.body, style: AppText.small),
                ],
                if (_relativeTime(notification.createdAt) case final time?) ...[
                  const SizedBox(height: 4),
                  Text(time, style: AppText.tiny),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _relativeTime(String iso) {
    if (iso.isEmpty) return null;
    final timestamp = DateTime.tryParse(iso);
    if (timestamp == null) return null;
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _AdminSection extends StatelessWidget {
  const _AdminSection({
    required this.index,
    required this.data,
    required this.repository,
    required this.onChanged,
  });

  final int index;
  final AdminDashboardData data;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return switch (index) {
      0 => _OverviewPanel(data: data),
      1 => _UsersPanel(
        users: data.users,
        repository: repository,
        onChanged: onChanged,
      ),
      2 => _KycPanel(
        users: data.users,
        kycProfiles: data.kycProfiles,
        repository: repository,
        onChanged: onChanged,
      ),
      3 => _AssetsPanel(
        assets: data.assets,
        repository: repository,
        onChanged: onChanged,
      ),
      4 => _PaymentsPanel(
        options: data.cryptoPaymentOptions,
        depositRequests: data.depositRequests,
        repository: repository,
        onChanged: onChanged,
      ),
      5 => _SupportPanel(
        tickets: data.supportTickets,
        repository: repository,
        onChanged: onChanged,
      ),
      6 => _ReportsPanel(data: data),
      _ => _SettingsPanel(
        policy: data.withdrawalPolicy,
        repository: repository,
        onChanged: onChanged,
      ),
    };
  }
}

class _OverviewPanel extends StatelessWidget {
  const _OverviewPanel({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    final activeUsers = data.users.where((user) => !user.disabled).length;
    final liveAssets = data.assets
        .where((asset) => asset.publishedStatus.toLowerCase() == 'live')
        .length;
    final enabledPaymentOptions = data.cryptoPaymentOptions
        .where((option) => option.enabled)
        .length;
    final pendingAssets = data.assets
        .where((asset) => asset.reviewStatus.toLowerCase() != 'verified')
        .length;
    final pendingDeposits = data.depositRequests
        .where((request) => request.status == 'proof_submitted')
        .length;
    final pendingSupport = data.supportTickets
        .where((ticket) => ticket.status == 'waiting_for_admin')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitor member activity, verified assets, and settlement flow.',
          style: TextStyle(color: AppColors.secondary, fontSize: 14),
        ),
        SizedBox(height: 26),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _AdminMetricCard(
              'Total users',
              '${data.users.length}',
              '$activeUsers active',
              Icons.people_alt_outlined,
            ),
            _AdminMetricCard(
              'Live assets',
              '$liveAssets',
              '${data.assets.length} total',
              Icons.apartment_outlined,
            ),
            _AdminMetricCard(
              'Payment options',
              '$enabledPaymentOptions',
              'enabled networks',
              Icons.currency_bitcoin_rounded,
            ),
            _AdminMetricCard(
              'Pending reviews',
              '${pendingAssets + pendingDeposits + pendingSupport}',
              '$pendingDeposits deposits',
              Icons.pending_actions_outlined,
              warning: true,
            ),
            _AdminMetricCard(
              'Support tickets',
              '${data.supportTickets.length}',
              '$pendingSupport need reply',
              Icons.support_agent_rounded,
              warning: pendingSupport > 0,
            ),
          ],
        ),
        SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final chart = _UserGrowthChart(data: data);
            final reviews = _PendingReviews(data: data);
            if (constraints.maxWidth < 850) {
              return Column(children: [chart, SizedBox(height: 18), reviews]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: chart),
                SizedBox(width: 18),
                Expanded(flex: 2, child: reviews),
              ],
            );
          },
        ),
        SizedBox(height: 20),
        _AdminPanel(
          title: 'Recent crypto payments',
          action: 'View all',
          child: _PaymentOptionTable(
            options: data.cryptoPaymentOptions,
            compact: true,
          ),
        ),
        SizedBox(height: 20),
        _AdminPanel(
          title: 'Recent users',
          action: 'Manage users',
          child: _UserTable(users: data.users, compact: true),
        ),
      ],
    );
  }
}

class _AdminErrorState extends StatelessWidget {
  const _AdminErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.gold,
              size: 34,
            ),
            SizedBox(height: 14),
            Text('Admin data unavailable', style: AppText.h2),
            SizedBox(height: 8),
            Text(
              message,
              style: AppText.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            SecondaryButton(label: 'Retry', onPressed: onRetry, compact: true),
          ],
        ),
      ),
    );
  }
}

class _AdminMetricCard extends StatelessWidget {
  const _AdminMetricCard(
    this.label,
    this.value,
    this.change,
    this.icon, {
    this.warning = false,
  });

  final String label;
  final String value;
  final String change;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 226,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.small,
                ),
              ),
              SizedBox(width: 8),
              Icon(icon, size: 20, color: AppColors.gold),
            ],
          ),
          SizedBox(height: 18),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            change,
            style: TextStyle(
              color: warning ? AppColors.warning : const Color(0xFF45C486),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPanel extends StatelessWidget {
  const _AdminPanel({required this.title, required this.child, this.action});

  final String title;
  final String? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (action != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(action!, style: AppText.eyebrow),
                ),
            ],
          ),
          SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

class _UserGrowthChart extends StatelessWidget {
  const _UserGrowthChart({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    final activeUsers = data.users.where((user) => !user.disabled).length;
    final admins = data.users.where((user) => user.admin).length;
    final verifiedEmails = data.users
        .where((user) => user.emailVerified)
        .length;
    final disabledUsers = data.users.where((user) => user.disabled).length;
    return _AdminPanel(
      title: 'User mix',
      action: '${data.users.length} total',
      child: SizedBox(
        height: 220,
        child: _BarChart(
          values: [
            data.users.length.toDouble(),
            activeUsers.toDouble(),
            verifiedEmails.toDouble(),
            admins.toDouble(),
            disabledUsers.toDouble(),
          ],
          labels: const ['All', 'Active', 'Email', 'Admin', 'Off'],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var index = 0; index < values.length; index++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: maxValue <= 0
                            ? 0
                            : values[index] / maxValue,
                        child: Container(
                          decoration: BoxDecoration(
                            color: index == values.length - 1
                                ? AppColors.gold
                                : AppColors.track,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(labels[index], style: AppText.tinyLight),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PendingReviews extends StatelessWidget {
  const _PendingReviews({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    final pendingAssets = data.assets
        .where((asset) => asset.reviewStatus.toLowerCase() != 'verified')
        .toList();
    final pendingDeposits = data.depositRequests
        .where((request) => request.status == 'proof_submitted')
        .toList();
    final pendingSupport = data.supportTickets
        .where((ticket) => ticket.status == 'waiting_for_admin')
        .toList();
    final rows = <Widget>[
      for (final asset in pendingAssets.take(2))
        _ReviewRow(asset.title, asset.reviewStatus, 'Asset'),
      for (final request in pendingDeposits.take(2))
        _ReviewRow(request.opportunityTitle, 'Deposit proof', 'Payment'),
      for (final ticket in pendingSupport.take(2))
        _ReviewRow(ticket.subject, ticket.requesterLabel, 'Support'),
    ];

    return _AdminPanel(
      title: 'Pending asset reviews',
      action: '${rows.length} shown',
      child: rows.isEmpty
          ? Text('No pending operational reviews.', style: AppText.body)
          : Column(children: rows),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.title, this.status, this.time);
  final String title;
  final String status;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.apartment_outlined,
              color: AppColors.gold,
              size: 19,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.fieldLabel),
                SizedBox(height: 3),
                Text(status, style: AppText.tinyLight),
              ],
            ),
          ),
          Text(time, style: AppText.tiny),
        ],
      ),
    );
  }
}

class _UsersPanel extends StatelessWidget {
  const _UsersPanel({
    required this.users,
    required this.repository,
    required this.onChanged,
  });

  final List<AdminUser> users;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description: 'Review verification, account status, and member activity.',
      actionLabel: 'Add user',
      onAction: () => _showUserDialog(
        context,
        repository: repository,
        onChanged: onChanged,
      ),
      child: _AdminPanel(
        title: 'Users',
        child: _UserTable(
          users: users,
          onEdit: (user) => _showUserDialog(
            context,
            repository: repository,
            user: user,
            onChanged: onChanged,
          ),
          onDelete: (user) => _runAdminAction(
            context,
            action: () => repository.deleteUser(user.uid),
            onChanged: onChanged,
          ),
          onToggleAdmin: (user, admin) => _runAdminAction(
            context,
            action: () => repository.setUserAdmin(uid: user.uid, admin: admin),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _KycPanel extends StatelessWidget {
  const _KycPanel({
    required this.users,
    required this.kycProfiles,
    required this.repository,
    required this.onChanged,
  });

  final List<AdminUser> users;
  final List<AdminKycProfile> kycProfiles;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final profileByUid = {
      for (final p in kycProfiles) p.uid: p,
    };
    final pending = kycProfiles.where((p) => p.needsReview).toList();

    return _SectionPage(
      description:
          'Review submitted KYC documents and manage identity verification status.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AdminPanel(
            title: 'Pending review (${pending.length})',
            child: _KycTable(
              profiles: pending,
              onApprove: (p) => _runAdminAction(
                context,
                action: () => repository.approveKycProfile(p.uid),
                onChanged: onChanged,
                successMessage: 'KYC approved',
              ),
              onReject: (p) => _showRejectKycDialog(
                context,
                repository: repository,
                profile: p,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(height: 24),
          _AdminPanel(
            title: 'All members (${users.length})',
            child: _KycMembersTable(
              users: users,
              profileByUid: profileByUid,
              onApprove: (user) => _runAdminAction(
                context,
                action: () => repository.approveKycProfile(user.uid),
                onChanged: onChanged,
                successMessage: 'KYC approved for ${user.displayName ?? user.email}',
              ),
              onReject: (user) {
                final profile = profileByUid[user.uid];
                if (profile != null) {
                  _showRejectKycDialog(
                    context,
                    repository: repository,
                    profile: profile,
                    onChanged: onChanged,
                  );
                } else {
                  showMessage(context, 'User has not submitted KYC');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KycTable extends StatelessWidget {
  const _KycTable({
    required this.profiles,
    required this.onApprove,
    required this.onReject,
  });

  final List<AdminKycProfile> profiles;
  final ValueChanged<AdminKycProfile> onApprove;
  final ValueChanged<AdminKycProfile> onReject;

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return Panel(
        child: Text('No KYC submissions pending review.', style: AppText.body),
      );
    }

    return _ResponsiveDataTable(
      columns: const ['Name', 'Email', 'Phone', 'Status'],
      rows: [
        for (final profile in profiles)
          _AdminTableRow(
            values: [
              profile.fullLegalName.isNotEmpty ? profile.fullLegalName : '-',
              profile.email,
              profile.phoneNumber.isNotEmpty ? profile.phoneNumber : '-',
              profile.statusLabel,
            ],
            source: profile,
          ),
      ],
      statusColumns: const {3},
      trailingBuilder: (row) {
        final profile = row.source as AdminKycProfile;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Approve KYC',
              icon: Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () => onApprove(profile),
            ),
            IconButton(
              tooltip: 'Reject KYC',
              icon: Icon(Icons.cancel_outlined, color: Colors.red.shade400),
              onPressed: () => onReject(profile),
            ),
          ],
        );
      },
    );
  }
}

class _KycMembersTable extends StatelessWidget {
  const _KycMembersTable({
    required this.users,
    required this.profileByUid,
    required this.onApprove,
    required this.onReject,
  });

  final List<AdminUser> users;
  final Map<String, AdminKycProfile> profileByUid;
  final ValueChanged<AdminUser> onApprove;
  final ValueChanged<AdminUser> onReject;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Panel(
        child: Text('No members found.', style: AppText.body),
      );
    }

    return _ResponsiveDataTable(
      columns: const ['Member', 'Email', 'KYC Status'],
      rows: [
        for (final user in users)
          _AdminTableRow(
            values: [
              user.displayName?.isNotEmpty == true ? user.displayName! : '-',
              user.email,
              profileByUid[user.uid]?.statusLabel ?? 'Not started',
            ],
            source: user,
          ),
      ],
      statusColumns: const {2},
      trailingBuilder: (row) {
        final user = row.source as AdminUser;
        final profile = profileByUid[user.uid];
        final isApproved = profile?.isApproved ?? false;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isApproved)
              IconButton(
                tooltip: 'Approve KYC',
                icon: Icon(Icons.verified_user_outlined, color: Colors.green),
                onPressed: () => onApprove(user),
              ),
            if (profile != null && !isApproved)
              IconButton(
                tooltip: 'Reject KYC',
                icon: Icon(Icons.cancel_outlined, color: Colors.red.shade400),
                onPressed: () => onReject(user),
              ),
          ],
        );
      },
    );
  }
}

Future<void> _showRejectKycDialog(
  BuildContext context, {
  required AdminRepository repository,
  required AdminKycProfile profile,
  required VoidCallback onChanged,
}) async {
  final reason = TextEditingController();
  await showAdaptiveDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text('Reject KYC', style: AppText.h2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rejecting KYC for ${profile.fullLegalName.isNotEmpty ? profile.fullLegalName : profile.email}.',
            style: AppText.body,
          ),
          SizedBox(height: 16),
          AppTextField(
            controller: reason,
            hintText: 'Reason shown to the member',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
          onPressed: () async {
            if (reason.text.trim().isEmpty) {
              showMessage(context, 'Enter a rejection reason');
              return;
            }
            Navigator.pop(dialogContext);
            await _runAdminAction(
              context,
              action: () => repository.rejectKycProfile(
                uid: profile.uid,
                reason: reason.text.trim(),
              ),
              onChanged: onChanged,
              successMessage: 'KYC rejected',
            );
          },
          child: Text('Reject'),
        ),
      ],
    ),
  );
  reason.dispose();
}

class _AssetsPanel extends StatelessWidget {
  const _AssetsPanel({
    required this.assets,
    required this.repository,
    required this.onChanged,
  });

  final List<AdminAsset> assets;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description:
          'Manage listings, due diligence, funding progress, and publication.',
      actionLabel: 'Add asset',
      onAction: () => _showAssetDialog(
        context,
        repository: repository,
        onChanged: onChanged,
      ),
      child: _AdminPanel(
        title: 'Asset inventory',
        child: _AssetTable(
          assets: assets,
          onEdit: (asset) => _showAssetDialog(
            context,
            repository: repository,
            asset: asset,
            onChanged: onChanged,
          ),
          onDelete: (asset) => _runAdminAction(
            context,
            action: () => repository.deleteAsset(asset.id),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _PaymentsPanel extends StatelessWidget {
  const _PaymentsPanel({
    required this.options,
    required this.depositRequests,
    required this.repository,
    required this.onChanged,
  });

  final List<CryptoPaymentOption> options;
  final List<AdminDepositRequest> depositRequests;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description:
          'Manage the crypto networks and wallet addresses offered in the app.',
      actionLabel: 'Add option',
      onAction: () => _showPaymentOptionDialog(
        context,
        repository: repository,
        onChanged: onChanged,
      ),
      child: _AdminPanel(
        title: 'Crypto payment options',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PaymentOptionTable(
              options: options,
              onEdit: (option) => _showPaymentOptionDialog(
                context,
                repository: repository,
                option: option,
                onChanged: onChanged,
              ),
              onDelete: (option) => _runAdminAction(
                context,
                action: () => repository.deleteCryptoPaymentOption(option.id),
                onChanged: onChanged,
              ),
            ),
            SizedBox(height: 24),
            Text('Deposit proof review', style: AppText.cardHeadingSmall),
            SizedBox(height: 12),
            _DepositRequestTable(
              requests: depositRequests,
              onVerify: (request) => _runAdminAction(
                context,
                action: () => repository.verifyDepositRequest(request.id),
                onChanged: onChanged,
              ),
              onReject: (request) => _showRejectDepositDialog(
                context,
                repository: repository,
                request: request,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositRequestTable extends StatelessWidget {
  const _DepositRequestTable({
    required this.requests,
    required this.onVerify,
    required this.onReject,
  });

  final List<AdminDepositRequest> requests;
  final ValueChanged<AdminDepositRequest> onVerify;
  final ValueChanged<AdminDepositRequest> onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Panel(
        child: Text('No submitted deposit proofs yet.', style: AppText.body),
      );
    }

    return _ResponsiveDataTable(
      columns: const ['Asset', 'Amount', 'Coin', 'Hash', 'Status'],
      rows: [
        for (final request in requests)
          _AdminTableRow(
            values: [
              request.opportunityTitle,
              request.amountUsd.toStringAsFixed(0),
              '${request.paymentAsset} ${request.paymentNetwork}',
              _shortHash(request.transactionHash),
              request.status,
            ],
            source: request,
          ),
      ],
      statusColumns: const {4},
      trailingBuilder: (row) {
        final request = row.source as AdminDepositRequest;
        final submitted = request.status == 'proof_submitted';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Open proof',
              onPressed: request.proofUrl.isEmpty
                  ? null
                  : () => showMessage(context, request.proofUrl),
              icon: Icon(Icons.receipt_long_outlined, size: 18),
            ),
            IconButton(
              tooltip: 'Verify',
              onPressed: submitted ? () => onVerify(request) : null,
              icon: Icon(Icons.verified_outlined, size: 18),
            ),
            IconButton(
              tooltip: 'Reject',
              onPressed: submitted ? () => onReject(request) : null,
              icon: Icon(Icons.close_rounded, size: 18),
            ),
          ],
        );
      },
    );
  }
}

class _SupportPanel extends StatelessWidget {
  const _SupportPanel({
    required this.tickets,
    required this.repository,
    required this.onChanged,
  });

  final List<AdminSupportTicket> tickets;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description: 'Review member support requests and reply from operations.',
      child: _AdminPanel(
        title: 'Support conversations',
        child: _SupportTicketTable(
          tickets: tickets,
          onReply: (ticket) => _showSupportReplyDialog(
            context,
            repository: repository,
            ticket: ticket,
            onChanged: onChanged,
          ),
          onClose: (ticket) => _runAdminAction(
            context,
            action: () => repository.closeSupportTicket(ticket.id),
            onChanged: onChanged,
            successMessage: 'Support request closed',
          ),
        ),
      ),
    );
  }
}

class _SupportTicketTable extends StatelessWidget {
  const _SupportTicketTable({
    required this.tickets,
    required this.onReply,
    required this.onClose,
  });

  final List<AdminSupportTicket> tickets;
  final ValueChanged<AdminSupportTicket> onReply;
  final ValueChanged<AdminSupportTicket> onClose;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return Panel(child: Text('No support tickets yet.', style: AppText.body));
    }

    return _ResponsiveDataTable(
      columns: const ['Member', 'Subject', 'Status', 'Messages'],
      rows: [
        for (final ticket in tickets)
          _AdminTableRow(
            values: [
              ticket.requesterLabel,
              ticket.subject,
              ticket.statusLabel,
              '${ticket.messageCount}',
            ],
            source: ticket,
          ),
      ],
      statusColumns: const {2},
      trailingBuilder: (row) {
        final ticket = row.source as AdminSupportTicket;
        final closed = ticket.status == 'closed';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Reply',
              onPressed: closed ? null : () => onReply(ticket),
              icon: Icon(Icons.reply_rounded, size: 18),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: closed ? null : () => onClose(ticket),
              icon: Icon(Icons.task_alt_rounded, size: 18),
            ),
          ],
        );
      },
    );
  }
}

class _ReportsPanel extends StatelessWidget {
  const _ReportsPanel({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    final verifiedAssets = data.assets
        .where((asset) => asset.reviewStatus.toLowerCase() == 'verified')
        .length;
    final liveAssets = data.assets
        .where((asset) => asset.publishedStatus.toLowerCase() == 'live')
        .length;
    final submittedDeposits = data.depositRequests
        .where((request) => request.status == 'proof_submitted')
        .length;
    final verifiedDeposits = data.depositRequests
        .where((request) => request.status == 'deposit_verified')
        .length;
    final rejectedDeposits = data.depositRequests
        .where((request) => request.status == 'deposit_rejected')
        .length;
    final openSupport = data.supportTickets
        .where((ticket) => ticket.status != 'closed')
        .length;

    return _SectionPage(
      description:
          'Operational reporting for member growth, assets, and settlement.',
      child: _AdminPanel(
        title: 'Operations report',
        child: SizedBox(
          height: 320,
          child: _BarChart(
            values: [
              data.users.length.toDouble(),
              verifiedAssets.toDouble(),
              liveAssets.toDouble(),
              submittedDeposits.toDouble(),
              verifiedDeposits.toDouble(),
              rejectedDeposits.toDouble(),
              openSupport.toDouble(),
            ],
            labels: const [
              'Users',
              'Verified',
              'Live',
              'Proofs',
              'Paid',
              'Rejected',
              'Support',
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.policy,
    required this.repository,
    required this.onChanged,
  });

  final WithdrawalPolicy policy;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description:
          'Configure approval rules, payment networks, and administrator access.',
      actionLabel: 'Edit withdrawals',
      onAction: () => _showWithdrawalPolicyDialog(
        context,
        repository: repository,
        policy: policy,
        onChanged: onChanged,
      ),
      child: _AdminPanel(
        title: 'Withdrawal requirements',
        child: Column(
          children: [
            _SettingRow(
              'Withdrawals',
              policy.enabled ? 'Enabled' : 'Disabled',
              switchValue: policy.enabled,
            ),
            _SettingRow(
              'Minimum amount',
              '\$${policy.minimumAmountUsd.toStringAsFixed(0)}',
            ),
            _SettingRow(
              'Fees',
              '\$${policy.flatFeeUsd.toStringAsFixed(0)} + ${policy.percentageFee.toStringAsFixed(2)}%',
            ),
            _SettingRow(
              'Destination wallet',
              policy.requiresDestinationWalletVerification
                  ? 'Verification required'
                  : 'Address format only',
              switchValue: policy.requiresDestinationWalletVerification,
            ),
            _SettingRow(
              'Approvals',
              '${policy.requiredApprovals} admin approval${policy.requiredApprovals == 1 ? '' : 's'}',
            ),
            _SettingRow('Processing time', policy.processingTime),
            _SettingRow('Notes', policy.notes),
          ],
        ),
      ),
    );
  }
}

class _SectionPage extends StatelessWidget {
  const _SectionPage({
    required this.description,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String description;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(description, style: AppText.bodyLarge),
        SizedBox(height: 24),
        Row(
          children: [
            const Spacer(),
            if (actionLabel != null)
              SecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
                compact: true,
              ),
          ],
        ),
        SizedBox(height: 20),
        child,
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow(this.title, this.value, {this.switchValue});
  final String title;
  final String value;
  final bool? switchValue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppText.fieldLabel),
      subtitle: Text(value, style: AppText.small),
      trailing: switchValue == null
          ? null
          : Switch(
              value: switchValue!,
              onChanged: null,
              activeThumbColor: AppColors.gold,
            ),
    );
  }
}

class _UserTable extends StatelessWidget {
  const _UserTable({
    required this.users,
    this.compact = false,
    this.onEdit,
    this.onDelete,
    this.onToggleAdmin,
  });

  final List<AdminUser> users;
  final bool compact;
  final ValueChanged<AdminUser>? onEdit;
  final ValueChanged<AdminUser>? onDelete;
  final void Function(AdminUser user, bool admin)? onToggleAdmin;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveDataTable(
      columns: const ['Member', 'Email', 'Role', 'Account'],
      rows: [
        for (final user in users.take(compact ? 4 : users.length))
          _AdminTableRow(
            values: [
              user.displayName?.isNotEmpty == true ? user.displayName! : '-',
              user.email,
              user.admin ? 'Admin' : 'Member',
              user.disabled ? 'Disabled' : 'Active',
            ],
            source: user,
          ),
      ],
      statusColumns: const {2, 3},
      onEdit: onEdit == null ? null : (row) => onEdit!(row.source as AdminUser),
      onDelete: onDelete == null
          ? null
          : (row) => onDelete!(row.source as AdminUser),
      trailingBuilder: compact || onToggleAdmin == null
          ? null
          : (row) {
              final user = row.source as AdminUser;
              return Switch(
                value: user.admin,
                onChanged: (value) => onToggleAdmin!(user, value),
                activeThumbColor: AppColors.gold,
              );
            },
    );
  }
}

class _AssetTable extends StatelessWidget {
  const _AssetTable({required this.assets, this.onEdit, this.onDelete});

  final List<AdminAsset> assets;
  final ValueChanged<AdminAsset>? onEdit;
  final ValueChanged<AdminAsset>? onDelete;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveDataTable(
      columns: const ['Asset', 'Type', 'Funded', 'Review', 'Published'],
      rows: [
        for (final asset in assets)
          _AdminTableRow(
            values: [
              asset.title,
              asset.type,
              '${asset.fundedPercent.toStringAsFixed(0)}%',
              asset.reviewStatus,
              asset.publishedStatus,
            ],
            source: asset,
          ),
      ],
      statusColumns: const {3, 4},
      onEdit: onEdit == null
          ? null
          : (row) => onEdit!(row.source as AdminAsset),
      onDelete: onDelete == null
          ? null
          : (row) => onDelete!(row.source as AdminAsset),
    );
  }
}

class _PaymentOptionTable extends StatelessWidget {
  const _PaymentOptionTable({
    required this.options,
    this.compact = false,
    this.onEdit,
    this.onDelete,
  });

  final List<CryptoPaymentOption> options;
  final bool compact;
  final ValueChanged<CryptoPaymentOption>? onEdit;
  final ValueChanged<CryptoPaymentOption>? onDelete;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveDataTable(
      columns: const ['Network', 'Asset', 'Wallet', 'QR', 'Minimum', 'Status'],
      rows: [
        for (final option in options.take(compact ? 4 : options.length))
          _AdminTableRow(
            values: [
              option.network,
              option.assetSymbol,
              option.walletAddress,
              option.qrCodeUrl.isEmpty ? 'Missing' : 'Uploaded',
              option.minimumAmount.toStringAsFixed(2),
              option.enabled ? 'Active' : 'Disabled',
            ],
            source: option,
          ),
      ],
      statusColumns: const {3, 5},
      onEdit: onEdit == null
          ? null
          : (row) => onEdit!(row.source as CryptoPaymentOption),
      onDelete: onDelete == null
          ? null
          : (row) => onDelete!(row.source as CryptoPaymentOption),
    );
  }
}

class _AdminTableRow {
  const _AdminTableRow({required this.values, this.source});

  final List<String> values;
  final Object? source;
}

class _ResponsiveDataTable extends StatelessWidget {
  const _ResponsiveDataTable({
    required this.columns,
    required this.rows,
    this.statusColumns = const {},
    this.onEdit,
    this.onDelete,
    this.trailingBuilder,
  });

  final List<String> columns;
  final List<_AdminTableRow> rows;
  final Set<int> statusColumns;
  final ValueChanged<_AdminTableRow>? onEdit;
  final ValueChanged<_AdminTableRow>? onDelete;
  final Widget Function(_AdminTableRow row)? trailingBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return Column(
            children: [
              for (final row in rows)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      for (var index = 0; index < columns.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 92,
                                child: Text(
                                  columns[index],
                                  style: AppText.tiny,
                                ),
                              ),
                              Expanded(
                                child: statusColumns.contains(index)
                                    ? Align(
                                        alignment: Alignment.centerLeft,
                                        child: _StatusChip(row.values[index]),
                                      )
                                    : Text(
                                        row.values[index],
                                        style: AppText.fieldLabel,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      if (onEdit != null ||
                          onDelete != null ||
                          trailingBuilder != null)
                        _RowActions(
                          onEdit: onEdit == null ? null : () => onEdit!(row),
                          onDelete: onDelete == null
                              ? null
                              : () => onDelete!(row),
                          trailing: trailingBuilder?.call(row),
                        ),
                    ],
                  ),
                ),
            ],
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            dataTextStyle: AppText.fieldLabel,
            headingRowHeight: 42,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 56,
            horizontalMargin: 8,
            columnSpacing: 34,
            dividerThickness: .5,
            border: TableBorder(
              horizontalInside: BorderSide(color: AppColors.border),
            ),
            columns: [
              for (final column in columns) DataColumn(label: Text(column)),
              if (onEdit != null || onDelete != null || trailingBuilder != null)
                const DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (final row in rows)
                DataRow(
                  cells: [
                    for (var index = 0; index < row.values.length; index++)
                      DataCell(
                        statusColumns.contains(index)
                            ? _StatusChip(row.values[index])
                            : Text(row.values[index]),
                      ),
                    if (onEdit != null ||
                        onDelete != null ||
                        trailingBuilder != null)
                      DataCell(
                        _RowActions(
                          onEdit: onEdit == null ? null : () => onEdit!(row),
                          onDelete: onDelete == null
                              ? null
                              : () => onDelete!(row),
                          trailing: trailingBuilder?.call(row),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({this.onEdit, this.onDelete, this.trailing});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?trailing,
        if (onEdit != null)
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 18),
          ),
        if (onDelete != null)
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, size: 18),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final positive = {
      'Verified',
      'Active',
      'Live',
      'Confirmed',
      'Uploaded',
      'deposit_verified',
    }.contains(label);
    final warning = {
      'Review',
      'Pending',
      'Draft',
      'proof_submitted',
    }.contains(label);
    final color = positive
        ? const Color(0xFF45C486)
        : warning
        ? AppColors.warning
        : const Color(0xFFE36D6D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<void> _showUserDialog(
  BuildContext context, {
  required AdminRepository repository,
  required VoidCallback onChanged,
  AdminUser? user,
}) async {
  final email = TextEditingController(text: user?.email ?? '');
  final name = TextEditingController(text: user?.displayName ?? '');
  final password = TextEditingController();
  var disabled = user?.disabled ?? false;
  var admin = user?.admin ?? false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: AppColors.panel,
          title: Text(user == null ? 'Create user' : 'Edit user'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: name,
                  hintText: 'Full name',
                  initialValue: null,
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: email,
                  hintText: 'member@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: password,
                  hintText: user == null
                      ? 'Temporary password'
                      : 'Leave blank to keep password',
                  obscureText: true,
                  initialValue: null,
                ),
                SwitchListTile(
                  value: admin,
                  onChanged: (value) => setState(() => admin = value),
                  title: Text('Admin access'),
                  activeThumbColor: AppColors.gold,
                ),
                SwitchListTile(
                  value: disabled,
                  onChanged: (value) => setState(() => disabled = value),
                  title: Text('Disabled'),
                  activeThumbColor: AppColors.gold,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await _runAdminAction(
                  context,
                  action: () => user == null
                      ? repository.createUser(
                          email: email.text,
                          password: password.text,
                          displayName: name.text,
                          disabled: disabled,
                          admin: admin,
                        )
                      : repository.updateUser(
                          uid: user.uid,
                          email: email.text,
                          password: password.text,
                          displayName: name.text,
                          disabled: disabled,
                          admin: admin,
                        ),
                  onChanged: onChanged,
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    ),
  );

  email.dispose();
  name.dispose();
  password.dispose();
}

Future<void> _showAssetDialog(
  BuildContext context, {
  required AdminRepository repository,
  required VoidCallback onChanged,
  AdminAsset? asset,
}) async {
  final value = asset ?? AdminAsset.empty();
  final title = TextEditingController(text: value.title);
  final location = TextEditingController(text: value.location);
  final type = TextEditingController(text: value.type);
  final fundedPercent = TextEditingController(
    text: value.fundedPercent.toStringAsFixed(0),
  );
  final reviewStatus = TextEditingController(text: value.reviewStatus);
  final publishedStatus = TextEditingController(text: value.publishedStatus);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text(asset == null ? 'Create asset' : 'Edit asset'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: title, hintText: 'Asset title'),
            SizedBox(height: 10),
            AppTextField(controller: location, hintText: 'Location'),
            SizedBox(height: 10),
            AppTextField(controller: type, hintText: 'Asset type'),
            SizedBox(height: 10),
            AppTextField(
              controller: fundedPercent,
              hintText: 'Funded percent',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            AppTextField(controller: reviewStatus, hintText: 'Review status'),
            SizedBox(height: 10),
            AppTextField(
              controller: publishedStatus,
              hintText: 'Published status',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final payload = AdminAsset(
              id: value.id,
              title: title.text,
              location: location.text,
              type: type.text,
              fundedPercent: double.tryParse(fundedPercent.text) ?? 0,
              reviewStatus: reviewStatus.text,
              publishedStatus: publishedStatus.text,
            );

            await _runAdminAction(
              context,
              action: () => asset == null
                  ? repository.createAsset(payload)
                  : repository.updateAsset(payload),
              onChanged: onChanged,
            );
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
          },
          child: Text('Save'),
        ),
      ],
    ),
  );

  title.dispose();
  location.dispose();
  type.dispose();
  fundedPercent.dispose();
  reviewStatus.dispose();
  publishedStatus.dispose();
}

Future<void> _showPaymentOptionDialog(
  BuildContext context, {
  required AdminRepository repository,
  required VoidCallback onChanged,
  CryptoPaymentOption? option,
}) async {
  final value = option ?? CryptoPaymentOption.empty();
  final network = TextEditingController(text: value.network);
  final assetSymbol = TextEditingController(text: value.assetSymbol);
  final walletAddress = TextEditingController(text: value.walletAddress);
  var qrCodeUrl = value.qrCodeUrl;
  final minimumAmount = TextEditingController(
    text: value.minimumAmount.toStringAsFixed(2),
  );
  var enabled = value.enabled;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: AppColors.panel,
          title: Text(option == null ? 'Create payment option' : 'Edit option'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(controller: network, hintText: 'Network'),
                SizedBox(height: 10),
                AppTextField(controller: assetSymbol, hintText: 'Asset symbol'),
                SizedBox(height: 10),
                AppTextField(
                  controller: walletAddress,
                  hintText: 'Settlement wallet address',
                ),
                SizedBox(height: 10),
                _PickerTile(
                  icon: Icons.qr_code_2_rounded,
                  title: qrCodeUrl.isEmpty
                      ? 'Upload payment QR code'
                      : 'QR code uploaded',
                  onTap: () async {
                    final uploaded = await _pickAdminQrCode(repository);
                    if (uploaded != null) {
                      setState(() => qrCodeUrl = uploaded);
                    }
                  },
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: minimumAmount,
                  hintText: 'Minimum amount',
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  value: enabled,
                  onChanged: (value) => setState(() => enabled = value),
                  title: Text('Enabled'),
                  activeThumbColor: AppColors.gold,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final payload = CryptoPaymentOption(
                  id: value.id,
                  network: network.text,
                  assetSymbol: assetSymbol.text,
                  walletAddress: walletAddress.text,
                  qrCodeUrl: qrCodeUrl,
                  enabled: enabled,
                  minimumAmount: double.tryParse(minimumAmount.text) ?? 0,
                );

                await _runAdminAction(
                  context,
                  action: () => option == null
                      ? repository.createCryptoPaymentOption(payload)
                      : repository.updateCryptoPaymentOption(payload),
                  onChanged: onChanged,
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    ),
  );

  network.dispose();
  assetSymbol.dispose();
  walletAddress.dispose();
  minimumAmount.dispose();
}

Future<String?> _pickAdminQrCode(AdminRepository repository) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    withData: true,
  );
  final file = result?.files.single;
  if (file?.bytes == null) return null;

  return repository.uploadCryptoPaymentQrCode(
    AdminUploadFile(
      name: file!.name,
      bytes: file.bytes!,
      contentType: _contentTypeForName(file.name),
    ),
  );
}

Future<void> _showRejectDepositDialog(
  BuildContext context, {
  required AdminRepository repository,
  required AdminDepositRequest request,
  required VoidCallback onChanged,
}) async {
  final reason = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text('Reject deposit proof'),
      content: SizedBox(
        width: 420,
        child: AppTextField(
          controller: reason,
          hintText: 'Reason shown to the member',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await _runAdminAction(
              context,
              action: () => repository.rejectDepositRequest(
                id: request.id,
                reason: reason.text,
              ),
              onChanged: onChanged,
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: Text('Reject'),
        ),
      ],
    ),
  );
  reason.dispose();
}

Future<void> _showWithdrawalPolicyDialog(
  BuildContext context, {
  required AdminRepository repository,
  required WithdrawalPolicy policy,
  required VoidCallback onChanged,
}) async {
  final minimum = TextEditingController(
    text: policy.minimumAmountUsd.toStringAsFixed(0),
  );
  final flatFee = TextEditingController(
    text: policy.flatFeeUsd.toStringAsFixed(0),
  );
  final percentageFee = TextEditingController(
    text: policy.percentageFee.toStringAsFixed(2),
  );
  final approvals = TextEditingController(
    text: policy.requiredApprovals.toString(),
  );
  final processingTime = TextEditingController(text: policy.processingTime);
  final notes = TextEditingController(text: policy.notes);
  var enabled = policy.enabled;
  var requiresWalletVerification = policy.requiresDestinationWalletVerification;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: AppColors.panel,
          title: Text('Withdrawal requirements'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    value: enabled,
                    onChanged: (value) => setState(() => enabled = value),
                    title: Text('Withdrawals enabled'),
                    activeThumbColor: AppColors.gold,
                  ),
                  SwitchListTile(
                    value: requiresWalletVerification,
                    onChanged: (value) =>
                        setState(() => requiresWalletVerification = value),
                    title: Text('Require wallet verification'),
                    activeThumbColor: AppColors.gold,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: minimum,
                    hintText: 'Minimum amount in USD',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: flatFee,
                    hintText: 'Flat fee in USD',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: percentageFee,
                    hintText: 'Percentage fee',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: approvals,
                    hintText: 'Required admin approvals',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: processingTime,
                    hintText: 'Processing time',
                  ),
                  SizedBox(height: 10),
                  AppTextField(controller: notes, hintText: 'Member notes'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final payload = WithdrawalPolicy(
                  minimumAmountUsd: double.tryParse(minimum.text) ?? 0,
                  flatFeeUsd: double.tryParse(flatFee.text) ?? 0,
                  percentageFee: double.tryParse(percentageFee.text) ?? 0,
                  requiresDestinationWalletVerification:
                      requiresWalletVerification,
                  requiredApprovals: int.tryParse(approvals.text) ?? 1,
                  processingTime: processingTime.text,
                  enabled: enabled,
                  notes: notes.text,
                );

                await _runAdminAction(
                  context,
                  action: () => repository.updateWithdrawalPolicy(payload),
                  onChanged: onChanged,
                  successMessage: 'Withdrawal requirements updated',
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    ),
  );

  minimum.dispose();
  flatFee.dispose();
  percentageFee.dispose();
  approvals.dispose();
  processingTime.dispose();
  notes.dispose();
}

Future<void> _showSupportReplyDialog(
  BuildContext context, {
  required AdminRepository repository,
  required AdminSupportTicket ticket,
  required VoidCallback onChanged,
}) async {
  final reply = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text('Reply to ${ticket.requesterLabel}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.subject, style: AppText.fieldLabel),
            if (ticket.latestMessage.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(ticket.latestMessage, style: AppText.body),
            ],
            SizedBox(height: 16),
            TextField(
              controller: reply,
              minLines: 4,
              maxLines: 6,
              style: TextStyle(color: AppColors.primary),
              decoration: InputDecoration(
                hintText: 'Type your reply',
                hintStyle: AppText.placeholder,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final message = reply.text.trim();
            if (message.isEmpty) {
              showMessage(context, 'Enter a reply');
              return;
            }
            await _runAdminAction(
              context,
              action: () => repository.replyToSupportTicket(
                id: ticket.id,
                message: message,
              ),
              onChanged: onChanged,
              successMessage: 'Support reply sent',
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: Text('Send reply'),
        ),
      ],
    ),
  );
  reply.dispose();
}

Future<void> _runAdminAction(
  BuildContext context, {
  required Future<void> Function() action,
  required VoidCallback onChanged,
  String successMessage = 'Admin change saved',
}) async {
  try {
    await action();
    onChanged();
    if (context.mounted) {
      showMessage(context, successMessage);
    }
  } catch (error) {
    if (context.mounted) {
      showMessage(context, _adminErrorMessage(error));
    }
  }
}

String _adminErrorMessage(Object error) {
  if (error is FirebaseFunctionsException) {
    return switch (error.code) {
      'unauthenticated' => 'Sign in again to continue.',
      'permission-denied' =>
        'Your account does not have permission to make this change.',
      'invalid-argument' =>
        'Check the details and try again. Some required information is missing or invalid.',
      'not-found' => 'We could not find that record. Refresh and try again.',
      'already-exists' => 'A record with those details already exists.',
      'unavailable' =>
        'Admin services are temporarily unavailable. Please try again shortly.',
      'deadline-exceeded' =>
        'The request took too long. Please check your connection and try again.',
      'resource-exhausted' =>
        'Too many requests right now. Please wait a moment and try again.',
      'failed-precondition' => _friendlyFirebaseMessage(
        error.message,
        fallback: 'This action is not available right now.',
      ),
      _ => 'We could not complete that admin action. Please try again.',
    };
  }

  return _friendlyUnexpectedMessage(error);
}

