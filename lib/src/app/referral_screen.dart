part of 'brickclub_app.dart';

/// "Refer & earn": shows the member's share code/link, how many people they've
/// referred, their lifetime commission earnings (paid into their wallet), and a
/// short history of recent commissions. Data comes from the referral backend.
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key, required this.repository});

  final ReferralRepository repository;

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  late Future<ReferralProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.getReferralProfile();
  }

  void _reload() {
    setState(() {
      _future = widget.repository.getReferralProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, l10n.referralScreenTitle),
        body: FutureBuilder<ReferralProfile>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _ReferralError(onRetry: _reload);
            }
            return _ReferralBody(profile: snapshot.data!);
          },
        ),
      ),
    );
  }
}

class _ReferralBody extends StatelessWidget {
  const _ReferralBody({required this.profile});

  final ReferralProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rate = _formatRate(profile.commissionPercent);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(l10n.referralHeadline, style: AppText.h2),
        SizedBox(height: 8),
        Text(l10n.referralHowItWorksBody(rate), style: AppText.bodyLarge),
        SizedBox(height: 18),
        _ReferralCodeCard(profile: profile),
        SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _ReferralStat(
                label: l10n.referralFriendsJoined,
                value: '${profile.referralCount}',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _ReferralStat(
                label: l10n.referralTotalEarned,
                value: _formatUsdAmount(profile.totalEarnedUsd),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Panel(
          child: Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  color: AppColors.gold, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.referralPaidToWalletNote(rate),
                  style: AppText.body,
                ),
              ),
            ],
          ),
        ),
        if (!profile.referralsEnabled) ...[
          SizedBox(height: 12),
          Panel(
            child: Text(l10n.referralDisabledNote, style: AppText.body),
          ),
        ],
        SizedBox(height: 22),
        Text(l10n.referralRecentEarningsTitle, style: AppText.h2),
        SizedBox(height: 12),
        if (profile.commissions.isEmpty)
          Panel(
            child: Text(l10n.referralNoEarningsYet, style: AppText.body),
          )
        else
          for (final commission in profile.commissions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReferralCommissionTile(commission: commission),
            ),
      ],
    );
  }
}

class _ReferralCodeCard extends StatelessWidget {
  const _ReferralCodeCard({required this.profile});

  final ReferralProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.referralYourCodeTitle, style: AppText.cardHeadingSmall),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              profile.hasCode ? profile.referralCode : '—',
              textAlign: TextAlign.center,
              style: AppText.h2.copyWith(letterSpacing: 4),
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  key: const ValueKey('referral-copy-code'),
                  label: l10n.referralCopyCode,
                  onPressed: profile.hasCode
                      ? () => _copy(context, profile.referralCode,
                          l10n.referralCopied)
                      : null,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  key: const ValueKey('referral-share-link'),
                  label: l10n.referralShareInvite,
                  onPressed: profile.hasCode
                      ? () => _shareLink(context, profile)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text, String confirm) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) showMessage(context, confirm);
  }

  Future<void> _shareLink(BuildContext context, ReferralProfile profile) async {
    final link = profile.shareLink(Uri.base.origin);
    await Clipboard.setData(ClipboardData(text: link));
    if (context.mounted) {
      showMessage(context, AppLocalizations.of(context).referralLinkCopied);
    }
  }
}

class _ReferralStat extends StatelessWidget {
  const _ReferralStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppText.h2),
          SizedBox(height: 4),
          Text(label, style: AppText.small),
        ],
      ),
    );
  }
}

class _ReferralCommissionTile extends StatelessWidget {
  const _ReferralCommissionTile({required this.commission});

  final ReferralCommission commission;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Panel(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.referralCommissionSubtitle(
                    _formatRate(commission.rate),
                    _formatUsdAmount(commission.investmentAmountUsd),
                  ),
                  style: AppText.body,
                ),
                if (commission.createdAt.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(_formatDate(commission.createdAt), style: AppText.small),
                ],
              ],
            ),
          ),
          SizedBox(width: 12),
          Text(
            '+${_formatUsdAmount(commission.commissionUsd)}',
            style: AppText.cardHeadingSmall.copyWith(color: AppColors.gold),
          ),
        ],
      ),
    );
  }
}

class _ReferralError extends StatelessWidget {
  const _ReferralError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.referralLoadError, style: AppText.body),
            SizedBox(height: 14),
            SecondaryButton(label: l10n.commonRetry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

String _formatRate(double percent) {
  final whole = percent.truncateToDouble() == percent;
  return '${percent.toStringAsFixed(whole ? 0 : 1)}%';
}

String _formatUsdAmount(double value) {
  return '\$${value.toStringAsFixed(2)}';
}

String _formatDate(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  return DateFormat.yMMMd().format(date.toLocal());
}
