part of 'brickclub_app.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.kyc,
    required this.supportRepository,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onStartKyc,
  });

  final SignedInUserDetails? user;
  final KycProfile kyc;
  final SupportRepository supportRepository;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onStartKyc;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Profile',
      simpleHeader: true,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          color: AppColors.panel,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.track,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.gold,
                  size: 28,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_profileName, style: AppText.h2),
                    Text(
                      _profileSubtitle,
                      style: AppText.body,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18),
        KycStatusCard(kyc: kyc, onStartKyc: onStartKyc),
        ProfileRow(
          key: const ValueKey('profile-settings'),
          title: 'Settings',
          subtitle: '${_themeModeLabel(themeMode)} theme',
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => ThemeSettingsScreen(
                themeMode: themeMode,
                onThemeModeChanged: onThemeModeChanged,
              ),
            ),
          ),
        ),
        for (final item in [
          ('Security & privacy', 'Verified wallet and biometrics'),
          ('Documents', 'Statements, risk disclosures'),
        ])
          ProfileRow(
            title: item.$1,
            subtitle: item.$2,
            onTap: () => showMessage(context, '${item.$1} opened'),
          ),
        ProfileRow(
          key: const ValueKey('profile-support'),
          title: 'Support',
          subtitle: 'Message the BrickClub team',
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => SupportScreen(repository: supportRepository),
            ),
          ),
        ),
      ],
    );
  }

  String get _profileName {
    final signedInName = user?.displayName?.trim();
    if (signedInName != null && signedInName.isNotEmpty) return signedInName;

    final legalName = kyc.fullLegalName?.trim();
    if (legalName != null && legalName.isNotEmpty) return legalName;

    return user?.primaryLabel ?? 'BrickClub member';
  }

  String get _profileSubtitle {
    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) return email;

    return 'Your account and BrickShares details';
  }
}

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, 'Theme'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Text('Appearance', style: AppText.h2),
            SizedBox(height: 8),
            Text(
              'Choose how BrickClub looks on this device.',
              style: AppText.bodyLarge,
            ),
            SizedBox(height: 18),
            Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final mode in ThemeMode.values)
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        key: ValueKey('theme-${mode.name}'),
                        title: Text(_themeModeLabel(mode), style: AppText.h2),
                        subtitle: Text(
                          _themeModeDescription(mode),
                          style: AppText.body,
                        ),
                        trailing: Icon(
                          themeMode == mode
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: themeMode == mode
                              ? AppColors.gold
                              : AppColors.muted,
                        ),
                        onTap: () => onThemeModeChanged(mode),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'System default',
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
};

String _themeModeDescription(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'Follow this device automatically.',
  ThemeMode.light => 'Use a bright interface with dark text.',
  ThemeMode.dark => 'Use the classic dark BrickClub interface.',
};

