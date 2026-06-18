part of 'brickclub_app.dart';

/// Hosts the authenticated bottom-navigation tabs.
///
/// The tab destinations are real go_router branches, so each one has its own
/// URL and back stack. This widget renders the persistent chrome (the phone
/// frame, scaffold, and bottom navigation bar) around the active branch and
/// exposes the live KYC profile plus branch switching to descendants through
/// [MemberScope].
class MemberShell extends StatelessWidget {
  const MemberShell({
    super.key,
    required this.navigationShell,
    required this.kycRepository,
  });

  final StatefulNavigationShell navigationShell;
  final KycRepository kycRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<KycProfile>(
      stream: kycRepository.watchProfile(),
      builder: (context, snapshot) {
        final kyc =
            snapshot.data ??
            const KycProfile(
              status: KycStatus.notStarted,
              emailVerified: false,
              phoneVerified: false,
            );
        return MemberScope(
          kyc: kyc,
          navigationShell: navigationShell,
          child: PhoneFrame(
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: navigationShell,
              bottomNavigationBar: AppBottomNav(
                index: navigationShell.currentIndex,
                onChanged: (value) => navigationShell.goBranch(
                  value,
                  initialLocation: value == navigationShell.currentIndex,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Provides the active KYC profile and branch navigation to the member tab
/// screens, so the screens stay reactive to KYC updates without threading the
/// stream through every constructor.
class MemberScope extends InheritedWidget {
  const MemberScope({
    super.key,
    required this.kyc,
    required this.navigationShell,
    required super.child,
  });

  final KycProfile kyc;
  final StatefulNavigationShell navigationShell;

  void goBranch(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  static MemberScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MemberScope>();
    assert(scope != null, 'MemberScope was not found in the widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(MemberScope oldWidget) =>
      kyc != oldWidget.kyc || navigationShell != oldWidget.navigationShell;
}

void requireApprovedKyc(
  BuildContext context,
  KycProfile kyc,
  VoidCallback onApproved,
  VoidCallback onStartKyc,
) {
  if (kyc.canPerformFinancialActions) {
    onApproved();
    return;
  }

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.panel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: AppColors.gold),
          SizedBox(height: 16),
          Text('Complete KYC first', style: AppText.h2),
          SizedBox(height: 8),
          Text(
            'Status: ${kyc.label}. Purchases, withdrawals, wallet changes, '
            'and crypto settlement unlock after approval.',
            style: AppText.bodyLarge,
          ),
          SizedBox(height: 20),
          PrimaryButton(
            key: const ValueKey('start-kyc-gate'),
            label: kyc.status == KycStatus.submitted
                ? 'View KYC status'
                : 'Complete KYC',
            onPressed: () {
              Navigator.pop(sheetContext);
              onStartKyc();
            },
          ),
        ],
      ),
    ),
  );
}

