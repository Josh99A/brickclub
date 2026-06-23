part of 'brickclub_app.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.kyc,
    required this.supportRepository,
    required this.referralRepository,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.locale,
    required this.onLocaleChanged,
    required this.onStartKyc,
    required this.onSignOut,
  });

  final SignedInUserDetails? user;
  final KycProfile kyc;
  final SupportRepository supportRepository;
  final ReferralRepository referralRepository;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Locale? locale;
  final ValueChanged<Locale?> onLocaleChanged;
  final VoidCallback onStartKyc;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      title: l10n.navProfile,
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
                    Text(_profileNameFor(l10n), style: AppText.h2),
                    Text(
                      _profileSubtitleFor(l10n),
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
          title: l10n.profileSettings,
          subtitle: l10n.profileThemeSubtitle(_themeModeLabel(l10n, themeMode)),
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => ThemeSettingsScreen(
                themeMode: themeMode,
                onThemeModeChanged: onThemeModeChanged,
              ),
            ),
          ),
        ),
        ProfileRow(
          key: const ValueKey('profile-language'),
          title: AppLocalizations.of(context).profileLanguage,
          subtitle: _languageLabel(context, locale),
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => LanguageSettingsScreen(
                locale: locale,
                onLocaleChanged: onLocaleChanged,
              ),
            ),
          ),
        ),
        for (final item in [
          (l10n.profileSecurityTitle, l10n.profileSecuritySubtitle),
          (l10n.profileDocumentsTitle, l10n.profileDocumentsSubtitle),
        ])
          ProfileRow(
            title: item.$1,
            subtitle: item.$2,
            onTap: () => showMessage(context, l10n.profileRowOpened(item.$1)),
          ),
        ProfileRow(
          key: const ValueKey('profile-referral'),
          title: l10n.profileReferral,
          subtitle: l10n.profileReferralSubtitle,
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => ReferralScreen(repository: referralRepository),
            ),
          ),
        ),
        ProfileRow(
          key: const ValueKey('profile-support'),
          title: l10n.profileSupport,
          subtitle: l10n.profileSupportSubtitle,
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => SupportScreen(repository: supportRepository),
            ),
          ),
        ),
        SizedBox(height: 18),
        _LogoutButton(onSignOut: () => _confirmSignOut(context)),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Text(l10n.profileLogoutConfirmTitle, style: AppText.h2),
        content: Text(
          l10n.profileLogoutConfirmBody,
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.profileLogout),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      onSignOut();
    }
  }

  String _profileNameFor(AppLocalizations l10n) {
    final signedInName = user?.displayName?.trim();
    if (signedInName != null && signedInName.isNotEmpty) return signedInName;

    final legalName = kyc.fullLegalName?.trim();
    if (legalName != null && legalName.isNotEmpty) return legalName;

    return user?.primaryLabel ?? l10n.profileDefaultName;
  }

  String _profileSubtitleFor(AppLocalizations l10n) {
    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) return email;

    return l10n.profileDefaultSubtitle;
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final color = Colors.red.shade400;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('profile-logout'),
        onTap: onSignOut,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 58,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.panel,
            border: Border.all(color: color.withValues(alpha: .4)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: color, size: 20),
              SizedBox(width: 14),
              Text(
                AppLocalizations.of(context).profileLogout,
                style: AppText.cardHeadingSmall.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  late ThemeMode _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.themeMode;
  }

  void _select(ThemeMode mode) {
    setState(() => _selected = mode);
    widget.onThemeModeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, l10n.themeScreenTitle),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Text(l10n.themeAppearance, style: AppText.h2),
            SizedBox(height: 8),
            Text(
              l10n.themeAppearanceDescription,
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
                        title: Text(
                          _themeModeLabel(l10n, mode),
                          style: AppText.h2,
                        ),
                        subtitle: Text(
                          _themeModeDescription(l10n, mode),
                          style: AppText.body,
                        ),
                        trailing: Icon(
                          _selected == mode
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: _selected == mode
                              ? AppColors.gold
                              : AppColors.muted,
                        ),
                        onTap: () => _select(mode),
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

String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
  ThemeMode.system => l10n.languageSystemDefault,
  ThemeMode.light => l10n.themeLight,
  ThemeMode.dark => l10n.themeDark,
};

String _themeModeDescription(AppLocalizations l10n, ThemeMode mode) =>
    switch (mode) {
      ThemeMode.system => l10n.themeSystemDescription,
      ThemeMode.light => l10n.themeLightDescription,
      ThemeMode.dark => l10n.themeDarkDescription,
    };

/// Selectable languages, labelled by their own endonym so each is recognisable
/// regardless of the currently active locale. Order matches business priority.
const _appLanguages = <({Locale locale, String endonym})>[
  (locale: Locale('en'), endonym: 'English'),
  (locale: Locale('zh'), endonym: '中文'),
  (locale: Locale('es'), endonym: 'Español'),
  (locale: Locale('it'), endonym: 'Italiano'),
  (locale: Locale('ru'), endonym: 'Русский'),
  (locale: Locale('ar'), endonym: 'العربية'),
  (locale: Locale('sw'), endonym: 'Kiswahili'),
  (locale: Locale('hi'), endonym: 'हिन्दी'),
];

/// Subtitle for the profile Language row: the active language's endonym, or the
/// localised "System default" when no explicit override is set.
String _languageLabel(BuildContext context, Locale? locale) {
  if (locale == null) return AppLocalizations.of(context).languageSystemDefault;
  for (final language in _appLanguages) {
    if (language.locale.languageCode == locale.languageCode) {
      return language.endonym;
    }
  }
  return AppLocalizations.of(context).languageSystemDefault;
}

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
  });

  final Locale? locale;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late Locale? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.locale;
  }

  void _select(Locale? locale) {
    setState(() => _selected = locale);
    widget.onLocaleChanged(locale);
  }

  bool _isSelected(Locale? locale) =>
      _selected?.languageCode == locale?.languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, l10n.languageScreenTitle),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Text(l10n.languageHeading, style: AppText.h2),
            SizedBox(height: 8),
            Text(l10n.languageDescription, style: AppText.bodyLarge),
            SizedBox(height: 18),
            Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _LanguageTile(
                    key: const ValueKey('language-system'),
                    label: l10n.languageSystemDefault,
                    selected: _isSelected(null),
                    onTap: () => _select(null),
                  ),
                  for (final language in _appLanguages)
                    _LanguageTile(
                      key: ValueKey('language-${language.locale.languageCode}'),
                      label: language.endonym,
                      selected: _isSelected(language.locale),
                      onTap: () => _select(language.locale),
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

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(label, style: AppText.h2),
        trailing: Icon(
          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: selected ? AppColors.gold : AppColors.muted,
        ),
        onTap: onTap,
      ),
    );
  }
}

