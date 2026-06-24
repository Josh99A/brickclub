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
    ('Payments', Icons.account_balance_wallet_rounded),
    ('Deposits', Icons.receipt_long_outlined),
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
                        onOpenSection: (index) =>
                            setState(() => selectedIndex = index),
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
    required this.onOpenSection,
  });

  final String title;
  final bool showMenu;
  final SignedInUserDetails? user;
  final List<AdminNotification> notifications;
  final Future<void> Function() onMarkNotificationsRead;
  final ValueChanged<int> onOpenSection;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 600;
    return Container(
      height: compact ? 62 : 78,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 24),
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
            SizedBox(width: compact ? 2 : 8),
          ],
          Flexible(
            child: Text(
              title == 'Overview' ? 'Admin overview' : title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: compact ? 18 : 23,
                fontWeight: FontWeight.w800,
              ),
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
            onOpenSection: onOpenSection,
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
    required this.onOpenSection,
  });

  final List<AdminNotification> notifications;
  final Future<void> Function() onMarkRead;
  final ValueChanged<int> onOpenSection;

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
        onOpenSection: onOpenSection,
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({
    required this.notifications,
    required this.onMarkRead,
    required this.onOpenSection,
  });

  final List<AdminNotification> notifications;
  final Future<void> Function() onMarkRead;
  final ValueChanged<int> onOpenSection;

  /// Maps an admin notification type to the dashboard section it should open.
  /// Sections: 0 Overview, 1 Users, 2 KYC, 3 Assets, 4 Payments, 5 Deposits,
  /// 6 Support, 7 Reports, 8 Settings.
  static int sectionForType(String type) {
    if (type.startsWith('deposit_')) return 5;
    if (type.startsWith('support_')) return 6;
    if (type.startsWith('kyc_')) return 2;
    if (type.startsWith('withdrawal_')) return 8;
    return 0;
  }

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
                  itemBuilder: (_, index) => _NotificationTile(
                    notification: notifications[index],
                    onTap: () {
                      Navigator.pop(context);
                      onOpenSection(
                        sectionForType(notifications[index].type),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AdminNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                  if (_relativeTime(notification.createdAt)
                      case final time?) ...[
                    const SizedBox(height: 4),
                    Text(time, style: AppText.tiny),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.muted,
            ),
          ],
        ),
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
        options: data.paymentOptions,
        repository: repository,
        onChanged: onChanged,
      ),
      5 => _DepositsPanel(
        depositRequests: data.depositRequests,
        repository: repository,
        onChanged: onChanged,
      ),
      6 => _SupportPanel(
        tickets: data.supportTickets,
        repository: repository,
        onChanged: onChanged,
      ),
      7 => _ReportsPanel(data: data),
      _ => _SettingsPanel(
        policy: data.withdrawalPolicy,
        referralPolicy: data.referralPolicy,
        landingContent: data.landingContent,
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
    final enabledPaymentOptions = data.paymentOptions
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
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 14.0;
            final width = constraints.maxWidth;
            final columns = width >= 900
                ? 4
                : width >= 620
                ? 3
                : width >= 360
                ? 2
                : 1;
            final cardWidth =
                (width - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _AdminMetricCard(
                  'Total users',
                  '${data.users.length}',
                  '$activeUsers active',
                  Icons.people_alt_outlined,
                  width: cardWidth,
                ),
                _AdminMetricCard(
                  'Live assets',
                  '$liveAssets',
                  '${data.assets.length} total',
                  Icons.apartment_outlined,
                  width: cardWidth,
                ),
                _AdminMetricCard(
                  'Payment methods',
                  '$enabledPaymentOptions',
                  'enabled methods',
                  Icons.account_balance_wallet_rounded,
                  width: cardWidth,
                ),
                _AdminMetricCard(
                  'Pending reviews',
                  '${pendingAssets + pendingDeposits + pendingSupport}',
                  '$pendingDeposits deposits',
                  Icons.pending_actions_outlined,
                  warning: true,
                  width: cardWidth,
                ),
                _AdminMetricCard(
                  'Support tickets',
                  '${data.supportTickets.length}',
                  '$pendingSupport need reply',
                  Icons.support_agent_rounded,
                  warning: pendingSupport > 0,
                  width: cardWidth,
                ),
              ],
            );
          },
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
          title: 'Payment methods',
          action: 'View all',
          child: _PaymentOptionTable(
            options: data.paymentOptions,
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
    this.width,
  });

  final String label;
  final String value;
  final String change;
  final IconData icon;
  final bool warning;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 226,
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
          onView: (user) => _showUserDetailDialog(
            context,
            repository: repository,
            user: user,
            onChanged: onChanged,
          ),
          onEdit: (user) => _showUserDialog(
            context,
            repository: repository,
            user: user,
            onChanged: onChanged,
          ),
          onDelete: (user) async {
            final label = user.displayName?.isNotEmpty == true
                ? user.displayName!
                : user.email;
            final confirmed = await _confirmDestructiveAction(
              context,
              title: 'Delete user?',
              message:
                  'This permanently deletes $label and removes their account '
                  'access. This action cannot be undone.',
            );
            if (!confirmed || !context.mounted) return;
            await _runAdminAction(
              context,
              action: () => repository.deleteUser(user.uid),
              onChanged: onChanged,
              successMessage: 'User deleted',
            );
          },
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
            label: 'Rejection reason',
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
          onDelete: (asset) async {
            final confirmed = await _confirmDestructiveAction(
              context,
              title: 'Delete asset?',
              message:
                  'This permanently removes "${asset.title}" from the catalog. '
                  'This action cannot be undone.',
            );
            if (!confirmed || !context.mounted) return;
            await _runAdminAction(
              context,
              action: () => repository.deleteAsset(asset.id),
              onChanged: onChanged,
              successMessage: 'Asset deleted',
            );
          },
          onValuation: (asset) => _showAssetValuationDialog(
            context,
            repository: repository,
            asset: asset,
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
    required this.repository,
    required this.onChanged,
  });

  final List<PaymentOption> options;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description:
          'Manage the payment methods — crypto wallets, Payoneer, Wise, Paytm — '
          'offered in the app. Members wire funds to the account details you '
          'enter here.',
      actionLabel: 'Add method',
      onAction: () => _showPaymentOptionDialog(
        context,
        repository: repository,
        onChanged: onChanged,
      ),
      child: _AdminPanel(
        title: 'Payment methods',
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
              onDelete: (option) async {
                final confirmed = await _confirmDestructiveAction(
                  context,
                  title: 'Delete payment method?',
                  message:
                      'This permanently removes the ${option.displayName} '
                      'payment method. This action cannot be undone.',
                );
                if (!confirmed || !context.mounted) return;
                await _runAdminAction(
                  context,
                  action: () => repository.deletePaymentOption(option.id),
                  onChanged: onChanged,
                  successMessage: 'Payment method deleted',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositsPanel extends StatelessWidget {
  const _DepositsPanel({
    required this.depositRequests,
    required this.repository,
    required this.onChanged,
  });

  final List<AdminDepositRequest> depositRequests;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final pending = depositRequests
        .where(
          (request) =>
              request.status == 'proof_submitted' ||
              request.status == 'pending_payment',
        )
        .length;
    return _SectionPage(
      description:
          'Review member deposit requests. Verify a submitted proof to credit '
          'the holding, approve a request whose funds you confirmed off-platform, '
          'or reject a proof that does not check out. The member is notified of '
          'the outcome.',
      child: _AdminPanel(
        title: pending > 0 ? 'Deposit requests ($pending awaiting review)'
            : 'Deposit requests',
        child: _DepositRequestTable(
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
        child: Text('No deposit requests yet.', style: AppText.body),
      );
    }

    return _ResponsiveDataTable(
      columns: const ['Asset', 'Amount', 'Method', 'Reference', 'Status'],
      rows: [
        for (final request in requests)
          _AdminTableRow(
            values: [
              request.opportunityTitle,
              request.amountUsd.toStringAsFixed(0),
              request.isCrypto
                  ? '${request.paymentAsset} ${request.paymentNetwork}'
                  : PaymentMethodType.label(request.paymentType),
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
        // Admins can verify a submitted proof, or manually approve a request
        // still awaiting payment (funds confirmed off-platform). Rejection only
        // applies to a submitted proof.
        final canVerify = submitted || request.status == 'pending_payment';
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
              tooltip: request.status == 'pending_payment'
                  ? 'Approve manually'
                  : 'Verify',
              onPressed: canVerify ? () => onVerify(request) : null,
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
    required this.referralPolicy,
    required this.landingContent,
    required this.repository,
    required this.onChanged,
  });

  final WithdrawalPolicy policy;
  final ReferralPolicy referralPolicy;
  final LandingContent landingContent;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description:
          'Configure approval rules, payment networks, and administrator access.',
      actionLabel: 'Edit withdrawals',
      actionIcon: Icons.edit_outlined,
      onAction: () => _showWithdrawalPolicyDialog(
        context,
        repository: repository,
        policy: policy,
        onChanged: onChanged,
      ),
      child: Column(
        children: [
          _AdminPanel(
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
          SizedBox(height: 24),
          _AdminPanel(
            title: 'Referral rewards',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingRow(
                  'Referral rewards',
                  referralPolicy.enabled ? 'Enabled' : 'Disabled',
                  switchValue: referralPolicy.enabled,
                ),
                _SettingRow(
                  'Commission',
                  '${referralPolicy.commissionPercent.toStringAsFixed(referralPolicy.commissionPercent.truncateToDouble() == referralPolicy.commissionPercent ? 0 : 2)}% of each investment',
                ),
                _SettingRow(
                  'Scope',
                  referralPolicy.firstInvestmentOnly
                      ? 'First investment only'
                      : 'Every investment',
                  switchValue: referralPolicy.firstInvestmentOnly,
                ),
                SizedBox(height: 12),
                _SectionActionButton(
                  label: 'Edit referrals',
                  icon: Icons.edit_outlined,
                  onPressed: () => _showReferralPolicyDialog(
                    context,
                    repository: repository,
                    policy: referralPolicy,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _AdminPanel(
            title: 'Landing page content',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingRow(
                  'Target return',
                  '${_trimNumber(landingContent.targetReturnPercent)}%',
                ),
                _SettingRow(
                  'Minimum investment',
                  '\$${_trimNumber(landingContent.minimumInvestmentUsd)}',
                ),
                _SettingRow(
                  'Settlement',
                  '${_trimNumber(landingContent.settlementPercent)}%',
                ),
                _SettingRow(
                  'Showcase portfolio value',
                  '\$${_trimNumber(landingContent.showcasePortfolioValueUsd)}',
                ),
                _SettingRow(
                  'Showcase asset name',
                  landingContent.showcaseAssetName,
                ),
                SizedBox(height: 12),
                _SectionActionButton(
                  label: 'Edit landing content',
                  icon: Icons.edit_outlined,
                  onPressed: () => _showLandingContentDialog(
                    context,
                    repository: repository,
                    content: landingContent,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats a marketing figure without a trailing `.0` for whole numbers.
String _trimNumber(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}

class _SectionPage extends StatelessWidget {
  const _SectionPage({
    required this.description,
    required this.child,
    this.actionLabel,
    this.actionIcon = Icons.add_rounded,
    this.onAction,
  });

  final String description;
  final Widget child;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final description = Text(this.description, style: AppText.bodyLarge);
            if (actionLabel == null) return description;
            // Stack the action below the description on narrow screens so the
            // button keeps its full label instead of crowding the text.
            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  description,
                  const SizedBox(height: 14),
                  _SectionActionButton(
                    label: actionLabel!,
                    icon: actionIcon,
                    onPressed: onAction,
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: description),
                const SizedBox(width: 16),
                _SectionActionButton(
                  label: actionLabel!,
                  icon: actionIcon,
                  onPressed: onAction,
                ),
              ],
            );
          },
        ),
        SizedBox(height: 20),
        child,
      ],
    );
  }
}

class _SectionActionButton extends StatelessWidget {
  const _SectionActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
    this.onView,
  });

  final List<AdminUser> users;
  final bool compact;
  final ValueChanged<AdminUser>? onEdit;
  final ValueChanged<AdminUser>? onDelete;
  final void Function(AdminUser user, bool admin)? onToggleAdmin;
  final ValueChanged<AdminUser>? onView;

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
      trailingBuilder: compact
          ? null
          : (row) {
              final user = row.source as AdminUser;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onView != null)
                    IconButton(
                      tooltip: 'View details',
                      onPressed: () => onView!(user),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                    ),
                  if (onToggleAdmin != null)
                    Switch(
                      value: user.admin,
                      onChanged: (value) => onToggleAdmin!(user, value),
                      activeThumbColor: AppColors.gold,
                    ),
                ],
              );
            },
    );
  }
}

class _AssetTable extends StatelessWidget {
  const _AssetTable({
    required this.assets,
    this.onEdit,
    this.onDelete,
    this.onValuation,
  });

  final List<AdminAsset> assets;
  final ValueChanged<AdminAsset>? onEdit;
  final ValueChanged<AdminAsset>? onDelete;
  final ValueChanged<AdminAsset>? onValuation;

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
      trailingBuilder: onValuation == null
          ? null
          : (row) => IconButton(
              tooltip: 'Update valuation',
              onPressed: () => onValuation!(row.source as AdminAsset),
              icon: Icon(Icons.trending_up_rounded, size: 18),
            ),
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

  final List<PaymentOption> options;
  final bool compact;
  final ValueChanged<PaymentOption>? onEdit;
  final ValueChanged<PaymentOption>? onDelete;

  static String _detailSummary(PaymentOption option) {
    if (option.isCrypto) return option.walletAddress;
    if (option.accountDetails.isEmpty) return '—';
    final first = option.accountDetails.first;
    final base = '${first.label}: ${first.value}';
    final extra = option.accountDetails.length - 1;
    return extra > 0 ? '$base  +$extra more' : base;
  }

  @override
  Widget build(BuildContext context) {
    return _ResponsiveDataTable(
      columns: const ['Method', 'Type', 'Details', 'QR', 'Minimum', 'Status'],
      rows: [
        for (final option in options.take(compact ? 4 : options.length))
          _AdminTableRow(
            values: [
              option.displayName,
              option.isCrypto ? 'Crypto' : PaymentMethodType.label(option.type),
              _detailSummary(option),
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
          : (row) => onEdit!(row.source as PaymentOption),
      onDelete: onDelete == null
          ? null
          : (row) => onDelete!(row.source as PaymentOption),
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

Future<void> _showUserDetailDialog(
  BuildContext context, {
  required AdminRepository repository,
  required AdminUser user,
  required VoidCallback onChanged,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      var detailFuture = repository.loadUserDetail(user.uid);
      return StatefulBuilder(
        builder: (statefulContext, setState) {
          return AlertDialog(
            backgroundColor: AppColors.panel,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user.displayName?.isNotEmpty == true
                        ? user.displayName!
                        : user.email,
                  ),
                ),
                IconButton(
                  tooltip: 'Edit user',
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _showUserDialog(
                      context,
                      repository: repository,
                      user: user,
                      onChanged: onChanged,
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
              ],
            ),
            content: SizedBox(
              width: 460,
              child: FutureBuilder<AdminUserDetail>(
                future: detailFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          'Could not load user details.\n${snapshot.error}',
                          style: AppText.small,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return _UserDetailBody(
                    detail: snapshot.data!,
                    repository: repository,
                    onWalletChanged: () {
                      onChanged();
                      setState(() {
                        detailFuture = repository.loadUserDetail(user.uid);
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _UserDetailBody extends StatelessWidget {
  const _UserDetailBody({
    required this.detail,
    required this.repository,
    required this.onWalletChanged,
  });

  final AdminUserDetail detail;
  final AdminRepository repository;
  final VoidCallback onWalletChanged;

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  String _date(String? value) {
    if (value == null || value.isEmpty) return '-';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _adjustWallet(BuildContext context, String direction) async {
    await _showWalletAdjustmentDialog(
      context,
      repository: repository,
      uid: detail.user.uid,
      direction: direction,
      onChanged: onWalletChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = detail.user;
    final kyc = detail.kyc;
    final portfolio = detail.portfolio;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _DetailSection('Account'),
          _DetailRow('User ID', user.uid),
          _DetailRow('Email', user.email),
          _DetailRow('Email verified', user.emailVerified ? 'Yes' : 'No'),
          _DetailRow(
            'Phone',
            user.phoneNumber.isNotEmpty ? user.phoneNumber : '-',
          ),
          _DetailRow('Role', user.admin ? 'Admin' : 'Member'),
          _DetailRow('Status', user.disabled ? 'Disabled' : 'Active'),
          _DetailRow('Created', _date(user.createdAt)),
          _DetailRow('Last sign-in', _date(user.lastSignInAt)),
          const SizedBox(height: 14),
          const _DetailSection('Wallet'),
          _DetailRow('Balance', _money(detail.wallet.balanceUsd)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _adjustWallet(context, 'credit'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add funds'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _adjustWallet(context, 'debit'),
                  icon: const Icon(Icons.remove_rounded, size: 18),
                  label: const Text('Deduct funds'),
                ),
              ),
            ],
          ),
          if (detail.wallet.transactions.isNotEmpty) ...[
            const SizedBox(height: 6),
            for (final tx in detail.wallet.transactions.take(8))
              _DetailRow(
                '${tx.isCredit ? '+' : '-'}${_money(tx.amountUsd)} · ${_date(tx.createdAt)}',
                tx.reason.isNotEmpty ? tx.reason : tx.type,
              ),
          ],
          const SizedBox(height: 14),
          const _DetailSection('KYC'),
          if (kyc == null)
            _DetailRow('Status', 'Not submitted')
          else ...[
            _DetailRow('Status', kyc.statusLabel),
            _DetailRow('Legal name', kyc.fullLegalName),
            _DetailRow('Date of birth', _date(kyc.dateOfBirth)),
            _DetailRow(
              'KYC phone',
              kyc.phoneNumber.isNotEmpty ? kyc.phoneNumber : '-',
            ),
            _DetailRow('Phone verified', kyc.phoneVerified ? 'Yes' : 'No'),
            if (kyc.rejectionReason.isNotEmpty)
              _DetailRow('Rejection reason', kyc.rejectionReason),
            _DetailRow('Submitted', _date(kyc.submittedAt)),
            if (kyc.governmentIdUrl.isNotEmpty ||
                kyc.selfieUrl.isNotEmpty ||
                kyc.addressProofUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (kyc.governmentIdUrl.isNotEmpty)
                      _DocLink('Government ID', kyc.governmentIdUrl),
                    if (kyc.selfieUrl.isNotEmpty)
                      _DocLink('Selfie', kyc.selfieUrl),
                    if (kyc.addressProofUrl.isNotEmpty)
                      _DocLink('Address proof', kyc.addressProofUrl),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 14),
          const _DetailSection('Portfolio'),
          _DetailRow('Total invested', _money(portfolio.totalInvested)),
          _DetailRow('Current value', _money(portfolio.totalCurrentValue)),
          _DetailRow('Dividends', _money(portfolio.totalDividends)),
          _DetailRow(
            'Profit / loss',
            '${_money(portfolio.totalProfitLoss)} '
                '(${portfolio.overallReturnPercentage.toStringAsFixed(2)}%)',
          ),
          if (portfolio.holdings.isNotEmpty) ...[
            const SizedBox(height: 6),
            for (final holding in portfolio.holdings)
              _DetailRow(
                holding.assetTitle.isNotEmpty ? holding.assetTitle : 'Holding',
                '${_money(holding.currentValue)} '
                    '(${holding.returnPercentage.toStringAsFixed(1)}%)',
              ),
          ],
          const SizedBox(height: 14),
          const _DetailSection('Recent orders'),
          if (detail.orders.isEmpty)
            _DetailRow('Orders', 'None')
          else
            for (final order in detail.orders.take(8))
              _DetailRow(
                order.opportunityTitle.isNotEmpty
                    ? order.opportunityTitle
                    : order.id,
                '${_money(order.amountUsd)} · ${order.status}',
              ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.gold,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: .6,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppText.tiny),
          ),
          Expanded(
            child: Text(value, style: AppText.fieldLabel),
          ),
        ],
      ),
    );
  }
}

class _DocLink extends StatelessWidget {
  const _DocLink(this.label, this.url);
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.description_outlined, size: 16),
      label: Text(label),
      onPressed: () => _openExternalUrl(context, url),
    );
  }
}

Future<void> _openExternalUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  final launched = uri == null
      ? false
      : await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    showMessage(context, 'Could not open $url');
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
  final phone = TextEditingController(text: user?.phoneNumber ?? '');
  final password = TextEditingController();
  var disabled = user?.disabled ?? false;
  var admin = user?.admin ?? false;
  var emailVerified = user?.emailVerified ?? false;

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
                  label: 'Full name',
                  hintText: 'Jane Doe',
                  initialValue: null,
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: email,
                  label: 'Email',
                  hintText: 'member@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: phone,
                  label: 'Phone number',
                  hintText: '+14155552671',
                  keyboardType: TextInputType.phone,
                  initialValue: null,
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: password,
                  label: 'Password',
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
                  value: emailVerified,
                  onChanged: (value) => setState(() => emailVerified = value),
                  title: Text('Email verified'),
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
                          emailVerified: emailVerified,
                          phoneNumber: phone.text.trim(),
                        )
                      : repository.updateUser(
                          uid: user.uid,
                          email: email.text,
                          password: password.text,
                          displayName: name.text,
                          disabled: disabled,
                          admin: admin,
                          emailVerified: emailVerified,
                          phoneNumber: phone.text.trim(),
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
  phone.dispose();
  password.dispose();
}

// Supported enumerations for asset inputs.
const _assetCategories = ['realEstate', 'reit', 'etf', 'index', 'alternative'];
const _assetStrategies = [
  'capitalGrowth',
  'highYield',
  'prime',
  'fixAndFlip',
  'fixToHighYield',
];
const _assetRiskLevels = ['conservative', 'balanced', 'growth'];
const _assetStatuses = [
  'available',
  'funded',
  'exited',
  'saved',
  'draft',
  'archived',
];
const _assetReviewStatuses = ['Pending', 'Verified'];
const _assetPublishedStatuses = ['Draft', 'Live'];

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
  final description = TextEditingController(text: value.description);
  final purchasePrice = TextEditingController(
    text: value.purchasePrice.toStringAsFixed(0),
  );
  final fundingTarget = TextEditingController(
    text: value.fundingTarget.toStringAsFixed(0),
  );
  final amountFunded = TextEditingController(
    text: value.amountFunded.toStringAsFixed(0),
  );
  final pricePerShare = TextEditingController(
    text: value.pricePerShare.toStringAsFixed(2),
  );
  final totalShares = TextEditingController(
    text: value.totalShares.toStringAsFixed(0),
  );
  final availableShares = TextEditingController(
    text: value.availableShares.toStringAsFixed(0),
  );
  final minimumInvestment = TextEditingController(
    text: value.minimumInvestment.toStringAsFixed(0),
  );
  final expectedAnnualYield = TextEditingController(
    text: value.expectedAnnualYield.toStringAsFixed(1),
  );
  final projectedNetYield = TextEditingController(
    text: value.projectedNetYield.toStringAsFixed(1),
  );
  final exitPeriod = TextEditingController(text: value.exitPeriod);
  final regulationNote = TextEditingController(text: value.regulationNote);
  var images = List<String>.from(value.images);
  var category = _assetCategories.contains(value.category)
      ? value.category
      : _assetCategories.first;
  var strategy = _assetStrategies.contains(value.strategy)
      ? value.strategy
      : _assetStrategies.first;
  var riskLevel = _assetRiskLevels.contains(value.riskLevel)
      ? value.riskLevel
      : _assetRiskLevels[1];
  var status = _assetStatuses.contains(value.status)
      ? value.status
      : _assetStatuses.first;
  var reviewStatus = _assetReviewStatuses.contains(value.reviewStatus)
      ? value.reviewStatus
      : _assetReviewStatuses.first;
  var publishedStatus = _assetPublishedStatuses.contains(value.publishedStatus)
      ? value.publishedStatus
      : _assetPublishedStatuses.first;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: AppColors.panel,
          title: Text(asset == null ? 'Create asset' : 'Edit asset'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: title,
                    label: 'Asset title',
                    hintText: 'e.g. Maple Court Residences',
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: location,
                    label: 'Location',
                    hintText: 'e.g. Austin, TX',
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: type,
                    label: 'Asset type',
                    hintText: 'e.g. Residential',
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: description,
                    label: 'Description',
                    hintText: 'Short summary of the asset',
                  ),
                  SizedBox(height: 10),
                  _AssetGalleryField(
                    images: images,
                    repository: repository,
                    onChanged: (next) => setState(() => images = next),
                  ),
                  SizedBox(height: 10),
                  _AssetDropdown(
                    label: 'Category',
                    value: category,
                    values: _assetCategories,
                    onChanged: (v) => setState(() => category = v),
                  ),
                  SizedBox(height: 10),
                  _AssetDropdown(
                    label: 'Strategy',
                    value: strategy,
                    values: _assetStrategies,
                    onChanged: (v) => setState(() => strategy = v),
                  ),
                  SizedBox(height: 10),
                  _AssetDropdown(
                    label: 'Risk level',
                    value: riskLevel,
                    values: _assetRiskLevels,
                    onChanged: (v) => setState(() => riskLevel = v),
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: purchasePrice,
                    label: 'Purchase price (USD)',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: fundingTarget,
                    label: 'Funding target (USD)',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: amountFunded,
                    label: 'Amount funded (USD)',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: pricePerShare,
                    label: 'Price per share (USD)',
                    hintText: '0.00',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: totalShares,
                    label: 'Total shares',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: availableShares,
                    label: 'Available shares',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: minimumInvestment,
                    label: 'Minimum investment (USD)',
                    hintText: '50',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: expectedAnnualYield,
                    label: 'Expected annual yield (%)',
                    hintText: '0.0',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: projectedNetYield,
                    label: 'Projected net yield (%)',
                    hintText: '0.0',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: exitPeriod,
                    label: 'Exit period',
                    hintText: 'e.g. 36 months',
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: regulationNote,
                    label: 'Regulation note',
                    hintText: 'Compliance disclosure',
                  ),
                  SizedBox(height: 10),
                  _AssetDropdown(
                    label: 'Asset status',
                    value: status,
                    values: _assetStatuses,
                    onChanged: (v) => setState(() => status = v),
                  ),
                  SizedBox(height: 10),
                  _AssetDropdown(
                    label: 'Review status',
                    value: reviewStatus,
                    values: _assetReviewStatuses,
                    onChanged: (v) => setState(() => reviewStatus = v),
                  ),
                  SizedBox(height: 10),
                  _AssetDropdown(
                    label: 'Published status',
                    value: publishedStatus,
                    values: _assetPublishedStatuses,
                    onChanged: (v) => setState(() => publishedStatus = v),
                  ),
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
                final payload = value.copyWith(
                  title: title.text.trim(),
                  location: location.text.trim(),
                  type: type.text.trim(),
                  description: description.text.trim(),
                  category: category,
                  images: images,
                  strategy: strategy,
                  riskLevel: riskLevel,
                  purchasePrice: double.tryParse(purchasePrice.text) ?? 0,
                  fundingTarget: double.tryParse(fundingTarget.text) ?? 0,
                  amountFunded: double.tryParse(amountFunded.text) ?? 0,
                  pricePerShare: double.tryParse(pricePerShare.text) ?? 0,
                  totalShares: double.tryParse(totalShares.text) ?? 0,
                  availableShares: double.tryParse(availableShares.text) ?? 0,
                  minimumInvestment:
                      double.tryParse(minimumInvestment.text) ?? 50,
                  expectedAnnualYield:
                      double.tryParse(expectedAnnualYield.text) ?? 0,
                  projectedNetYield:
                      double.tryParse(projectedNetYield.text) ?? 0,
                  exitPeriod: exitPeriod.text.trim(),
                  regulationNote: regulationNote.text.trim(),
                  status: status,
                  reviewStatus: reviewStatus,
                  publishedStatus: publishedStatus,
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
        );
      },
    ),
  );

  title.dispose();
  location.dispose();
  type.dispose();
  description.dispose();
  purchasePrice.dispose();
  fundingTarget.dispose();
  amountFunded.dispose();
  pricePerShare.dispose();
  totalShares.dispose();
  availableShares.dispose();
  minimumInvestment.dispose();
  expectedAnnualYield.dispose();
  projectedNetYield.dispose();
  exitPeriod.dispose();
  regulationNote.dispose();
}

class _AssetDropdown extends StatelessWidget {
  const _AssetDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    this.labelFor,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  /// Optional mapper from a raw [values] entry to its display text. Defaults to
  /// showing the raw value.
  final String Function(String value)? labelFor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: AppColors.panel,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppText.small,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      style: AppText.fieldLabel,
      items: [
        for (final option in values)
          DropdownMenuItem(
            value: option,
            child: Text(labelFor?.call(option) ?? option),
          ),
      ],
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}

class _AssetGalleryField extends StatefulWidget {
  const _AssetGalleryField({
    required this.images,
    required this.repository,
    required this.onChanged,
  });

  final List<String> images;
  final AdminRepository repository;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_AssetGalleryField> createState() => _AssetGalleryFieldState();
}

class _AssetGalleryFieldState extends State<_AssetGalleryField> {
  bool _uploading = false;

  Future<void> _addImages() async {
    setState(() => _uploading = true);
    try {
      final uploaded = await _pickAdminAssetImages(widget.repository);
      if (uploaded.isNotEmpty) {
        widget.onChanged([...widget.images, ...uploaded]);
      }
    } catch (error) {
      if (mounted) showMessage(context, _adminErrorMessage(error));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _removeAt(int index) {
    final next = [...widget.images]..removeAt(index);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text('Photos / gallery', style: AppText.fieldLabel),
        ),
        if (widget.images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < widget.images.length; index++)
                  _AssetGalleryThumb(
                    url: widget.images[index],
                    onRemove: () => _removeAt(index),
                  ),
              ],
            ),
          ),
        _PickerTile(
          icon: _uploading
              ? Icons.hourglass_top_rounded
              : Icons.add_photo_alternate_outlined,
          title: _uploading
              ? 'Uploading photos…'
              : widget.images.isEmpty
              ? 'Add asset photos'
              : 'Add more photos (${widget.images.length})',
          onTap: _uploading ? () {} : _addImages,
        ),
      ],
    );
  }
}

class _AssetGalleryThumb extends StatelessWidget {
  const _AssetGalleryThumb({required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            width: 84,
            height: 84,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 84,
              height: 84,
              color: AppColors.surface,
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.muted,
                size: 22,
              ),
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: const Icon(
                Icons.close_rounded,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<List<String>> _pickAdminAssetImages(AdminRepository repository) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    withData: true,
    allowMultiple: true,
  );
  if (result == null) return const [];

  final urls = <String>[];
  for (final file in result.files) {
    final bytes = file.bytes;
    if (bytes == null) continue;
    final url = await repository.uploadAssetImage(
      AdminUploadFile(
        name: file.name,
        bytes: bytes,
        contentType: _contentTypeForName(file.name),
      ),
    );
    urls.add(url);
  }
  return urls;
}

Future<void> _showAssetValuationDialog(
  BuildContext context, {
  required AdminRepository repository,
  required AdminAsset asset,
  required VoidCallback onChanged,
}) async {
  final currentValue = TextEditingController(
    text: asset.currentAssetValue > 0
        ? asset.currentAssetValue.toStringAsFixed(0)
        : '',
  );
  final valuationDate = TextEditingController();
  final assetIncome = TextEditingController();
  final expenses = TextEditingController();
  final occupancyRate = TextEditingController();
  final notes = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text('Update valuation'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(asset.title, style: AppText.fieldLabel),
              SizedBox(height: 12),
              AppTextField(
                controller: currentValue,
                label: 'Current asset value (USD)',
                hintText: '0',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              AppTextField(
                controller: valuationDate,
                label: 'Valuation date',
                hintText: 'YYYY-MM-DD',
              ),
              SizedBox(height: 10),
              AppTextField(
                controller: assetIncome,
                label: 'Asset/rental income (USD)',
                hintText: '0',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              AppTextField(
                controller: expenses,
                label: 'Expenses (USD)',
                hintText: '0',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              AppTextField(
                controller: occupancyRate,
                label: 'Occupancy rate (%)',
                hintText: '0',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              AppTextField(
                controller: notes,
                label: 'Performance notes',
                hintText: 'Optional commentary',
              ),
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
            final parsedValue = double.tryParse(currentValue.text) ?? 0;
            if (parsedValue <= 0) {
              showMessage(context, 'Enter a current asset value');
              return;
            }
            final income = double.tryParse(assetIncome.text) ?? 0;
            final cost = double.tryParse(expenses.text) ?? 0;
            await _runAdminAction(
              context,
              action: () => repository.updateAssetValuation(
                id: asset.id,
                currentAssetValue: parsedValue,
                valuationDate: valuationDate.text.trim(),
                performanceNotes: notes.text.trim(),
                assetIncome: income,
                expenses: cost,
                netIncome: income - cost,
                occupancyRate: double.tryParse(occupancyRate.text) ?? 0,
              ),
              onChanged: onChanged,
              successMessage: 'Valuation updated',
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: Text('Save valuation'),
        ),
      ],
    ),
  );

  currentValue.dispose();
  valuationDate.dispose();
  assetIncome.dispose();
  expenses.dispose();
  occupancyRate.dispose();
  notes.dispose();
}

/// Two controllers backing one editable account-detail row in the dialog.
class _AccountFieldEditor {
  _AccountFieldEditor({String label = '', String value = ''})
    : label = TextEditingController(text: label),
      value = TextEditingController(text: value);

  final TextEditingController label;
  final TextEditingController value;

  void dispose() {
    label.dispose();
    value.dispose();
  }
}

Future<void> _showPaymentOptionDialog(
  BuildContext context, {
  required AdminRepository repository,
  required VoidCallback onChanged,
  PaymentOption? option,
}) async {
  final value = option ?? PaymentOption.empty();
  var type = value.type;
  final network = TextEditingController(text: value.network);
  final assetSymbol = TextEditingController(text: value.assetSymbol);
  final walletAddress = TextEditingController(text: value.walletAddress);
  var qrCodeUrl = value.qrCodeUrl;
  final minimumAmount = TextEditingController(
    text: value.minimumAmount.toStringAsFixed(2),
  );
  var enabled = value.enabled;
  final accountRows = <_AccountFieldEditor>[
    for (final field in value.accountDetails)
      _AccountFieldEditor(label: field.label, value: field.value),
  ];

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        final isCrypto = type == PaymentMethodType.crypto;
        return AlertDialog(
          backgroundColor: AppColors.panel,
          title: Text(
            option == null ? 'Add payment method' : 'Edit payment method',
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AssetDropdown(
                    label: 'Method type',
                    value: type,
                    values: const [
                      PaymentMethodType.crypto,
                      ...PaymentMethodType.accountTypes,
                    ],
                    onChanged: (selected) => setState(() => type = selected),
                    labelFor: PaymentMethodType.label,
                  ),
                  SizedBox(height: 10),
                  if (isCrypto) ...[
                    AppTextField(
                      controller: network,
                      label: 'Network',
                      hintText: 'e.g. Bitcoin, Ethereum (ERC-20)',
                    ),
                    SizedBox(height: 10),
                    AppTextField(
                      controller: assetSymbol,
                      label: 'Asset symbol',
                      hintText: 'e.g. BTC, USDT',
                    ),
                    SizedBox(height: 10),
                    AppTextField(
                      controller: walletAddress,
                      label: 'Settlement wallet address',
                      hintText: 'Receiving wallet address',
                    ),
                    SizedBox(height: 10),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 4),
                      child: Text('Account details', style: AppText.fieldLabel),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 8),
                      child: Text(
                        'Fields members see and wire funds to — e.g. Account '
                        'holder, Email, IBAN, UPI ID.',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    for (var i = 0; i < accountRows.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: accountRows[i].label,
                                label: 'Label',
                                hintText: 'e.g. IBAN',
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: AppTextField(
                                controller: accountRows[i].value,
                                label: 'Value',
                                hintText: 'e.g. GB12 ...',
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.secondary,
                              ),
                              tooltip: 'Remove field',
                              onPressed: () => setState(
                                () => accountRows.removeAt(i).dispose(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(
                          () => accountRows.add(_AccountFieldEditor()),
                        ),
                        icon: Icon(Icons.add, color: AppColors.gold),
                        label: Text(
                          'Add field',
                          style: TextStyle(color: AppColors.gold),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                  _PickerTile(
                    icon: Icons.qr_code_2_rounded,
                    title: qrCodeUrl.isEmpty
                        ? 'Upload payment QR code (optional)'
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
                    label: 'Minimum amount',
                    hintText: '0.00',
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final isCryptoSel = type == PaymentMethodType.crypto;
                final payload = PaymentOption(
                  id: value.id,
                  type: type,
                  // Non-crypto methods derive a stable code/label from the type
                  // and carry their specifics in accountDetails instead.
                  network: isCryptoSel
                      ? network.text
                      : PaymentMethodType.label(type),
                  assetSymbol: isCryptoSel
                      ? assetSymbol.text
                      : type.toUpperCase(),
                  walletAddress: isCryptoSel ? walletAddress.text : '',
                  qrCodeUrl: qrCodeUrl,
                  accountDetails: isCryptoSel
                      ? const []
                      : [
                          for (final row in accountRows)
                            if (row.label.text.trim().isNotEmpty ||
                                row.value.text.trim().isNotEmpty)
                              PaymentAccountField(
                                label: row.label.text.trim(),
                                value: row.value.text.trim(),
                              ),
                        ],
                  enabled: enabled,
                  minimumAmount: double.tryParse(minimumAmount.text) ?? 0,
                );

                await _runAdminAction(
                  context,
                  action: () => option == null
                      ? repository.createPaymentOption(payload)
                      : repository.updatePaymentOption(payload),
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
  for (final row in accountRows) {
    row.dispose();
  }
}

Future<String?> _pickAdminQrCode(AdminRepository repository) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    withData: true,
  );
  final file = result?.files.single;
  if (file?.bytes == null) return null;

  return repository.uploadPaymentQrCode(
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
          label: 'Rejection reason',
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

Future<void> _showWalletAdjustmentDialog(
  BuildContext context, {
  required AdminRepository repository,
  required String uid,
  required String direction,
  required VoidCallback onChanged,
}) async {
  final isCredit = direction == 'credit';
  final amount = TextEditingController();
  final reason = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text(isCredit ? 'Add funds to wallet' : 'Deduct funds from wallet'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: amount,
              label: 'Amount (USD)',
              hintText: '0.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: reason,
              label: 'Reason',
              hintText: isCredit
                  ? 'e.g. Bank transfer received off-platform'
                  : 'e.g. Correcting a duplicate credit',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final value = double.tryParse(amount.text.trim());
            if (value == null || value <= 0) {
              showMessage(context, 'Enter an amount greater than 0.');
              return;
            }
            if (reason.text.trim().isEmpty) {
              showMessage(context, 'A reason is required.');
              return;
            }
            await _runAdminAction(
              context,
              action: () => repository.adjustMemberWallet(
                uid: uid,
                amountUsd: value,
                direction: direction,
                reason: reason.text.trim(),
              ),
              onChanged: onChanged,
              successMessage: isCredit ? 'Funds added' : 'Funds deducted',
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: Text(isCredit ? 'Add funds' : 'Deduct funds'),
        ),
      ],
    ),
  );
  amount.dispose();
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
                    label: 'Minimum amount (USD)',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: flatFee,
                    label: 'Flat fee (USD)',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: percentageFee,
                    label: 'Percentage fee',
                    hintText: '0.00',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: approvals,
                    label: 'Required admin approvals',
                    hintText: '1',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: processingTime,
                    label: 'Processing time',
                    hintText: 'e.g. 1-3 business days',
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: notes,
                    label: 'Member notes',
                    hintText: 'Shown to members',
                  ),
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

Future<void> _showReferralPolicyDialog(
  BuildContext context, {
  required AdminRepository repository,
  required ReferralPolicy policy,
  required VoidCallback onChanged,
}) async {
  final commissionPercent = TextEditingController(
    text: policy.commissionPercent.toStringAsFixed(
      policy.commissionPercent.truncateToDouble() == policy.commissionPercent
          ? 0
          : 2,
    ),
  );
  var enabled = policy.enabled;
  var firstInvestmentOnly = policy.firstInvestmentOnly;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: AppColors.panel,
          title: Text('Referral rewards'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    value: enabled,
                    onChanged: (value) => setState(() => enabled = value),
                    title: Text('Referral rewards enabled'),
                    activeThumbColor: AppColors.gold,
                  ),
                  SwitchListTile(
                    value: firstInvestmentOnly,
                    onChanged: (value) =>
                        setState(() => firstInvestmentOnly = value),
                    title: Text('First investment only'),
                    subtitle: Text(
                      'Pay commission only on each referral\'s first '
                      'verified investment.',
                    ),
                    activeThumbColor: AppColors.gold,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: commissionPercent,
                    label: 'Commission percent',
                    hintText: '5',
                    keyboardType: TextInputType.number,
                  ),
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
                final payload = ReferralPolicy(
                  enabled: enabled,
                  commissionPercent:
                      double.tryParse(commissionPercent.text) ?? 0,
                  firstInvestmentOnly: firstInvestmentOnly,
                );

                await _runAdminAction(
                  context,
                  action: () => repository.updateReferralPolicy(payload),
                  onChanged: onChanged,
                  successMessage: 'Referral rewards updated',
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

  commissionPercent.dispose();
}

Future<void> _showLandingContentDialog(
  BuildContext context, {
  required AdminRepository repository,
  required LandingContent content,
  required VoidCallback onChanged,
}) async {
  final targetReturn = TextEditingController(
    text: _trimNumber(content.targetReturnPercent),
  );
  final minimum = TextEditingController(
    text: _trimNumber(content.minimumInvestmentUsd),
  );
  final settlement = TextEditingController(
    text: _trimNumber(content.settlementPercent),
  );
  final portfolioValue = TextEditingController(
    text: _trimNumber(content.showcasePortfolioValueUsd),
  );
  final assetName = TextEditingController(text: content.showcaseAssetName);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text('Landing page content'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: targetReturn,
                label: 'Target return (%)',
                hintText: '12.4',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              AppTextField(
                controller: minimum,
                label: 'Minimum investment (USD)',
                hintText: '50',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              AppTextField(
                controller: settlement,
                label: 'Settlement (%)',
                hintText: '100',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              AppTextField(
                controller: portfolioValue,
                label: 'Showcase portfolio value (USD)',
                hintText: '5000',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              AppTextField(
                controller: assetName,
                label: 'Showcase asset name',
                hintText: 'Skyline Heights Income Fund',
              ),
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
            final payload = LandingContent(
              targetReturnPercent:
                  double.tryParse(targetReturn.text) ??
                  content.targetReturnPercent,
              minimumInvestmentUsd:
                  double.tryParse(minimum.text) ??
                  content.minimumInvestmentUsd,
              settlementPercent:
                  double.tryParse(settlement.text) ??
                  content.settlementPercent,
              showcasePortfolioValueUsd:
                  double.tryParse(portfolioValue.text) ??
                  content.showcasePortfolioValueUsd,
              showcaseAssetName: assetName.text.trim().isEmpty
                  ? content.showcaseAssetName
                  : assetName.text.trim(),
            );

            await _runAdminAction(
              context,
              action: () => repository.updateLandingContent(payload),
              onChanged: onChanged,
              successMessage: 'Landing content updated',
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: Text('Save'),
        ),
      ],
    ),
  );

  targetReturn.dispose();
  minimum.dispose();
  settlement.dispose();
  portfolioValue.dispose();
  assetName.dispose();
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
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 6),
              child: Text('Your reply', style: AppText.fieldLabel),
            ),
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

/// Shows a confirmation dialog before a destructive, irreversible admin action
/// (e.g. deleting a user, asset, or payment option). Returns `true` only when
/// the admin explicitly confirms.
Future<bool> _confirmDestructiveAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  final confirmed = await showAdaptiveDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text(title, style: AppText.h2),
      content: Text(message, style: AppText.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
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

