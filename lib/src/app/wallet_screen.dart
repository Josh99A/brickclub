part of 'brickclub_app.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({
    super.key,
    required this.kyc,
    required this.investmentRepository,
    required this.onStartKyc,
    required this.onOpenProfile,
  });

  final KycProfile kyc;
  final InvestmentRepository investmentRepository;
  final VoidCallback onStartKyc;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Wallet',
      onProfileTap: onOpenProfile,
      children: [
        FutureBuilder<MemberDashboardData>(
          future: investmentRepository.loadMemberDashboard(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _DashboardLoadingPanel();
            }
            if (snapshot.hasError) {
              return const _DashboardErrorPanel();
            }
            final data = snapshot.data ?? MemberDashboardData.empty();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WalletBalanceCard(data: data),
                SizedBox(height: 18),
                Text('Crypto order activity', style: AppText.h2),
                _ActivityPanel(activity: data.activity),
              ],
            );
          },
        ),
        KycStatusCard(kyc: kyc, onStartKyc: onStartKyc, compact: true),
        SizedBox(height: 28),
        Panel(
          child: Column(
            children: [
              Text(
                'Crypto funding readiness',
                style: AppText.cardHeading,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Add a verified wallet before sending funds. Network, fees, '
                'quote expiry, and settlement status are shown before confirmation.',
                textAlign: TextAlign.center,
                style: AppText.body,
              ),
              SizedBox(height: 20),
              PrimaryButton(
                label: 'Add verified wallet',
                height: 46,
                onPressed: () => requireApprovedKyc(
                  context,
                  kyc,
                  () => showMessage(context, 'Wallet verification started'),
                  onStartKyc,
                ),
              ),
            ],
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settlement confirmation required',
                style: AppText.cardHeadingSmall,
              ),
              SizedBox(height: 10),
              Text(
                'Purchases, withdrawals, and wallet changes require final confirmation.',
                style: AppText.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard({required this.data});

  final MemberDashboardData data;

  @override
  Widget build(BuildContext context) {
    final hasRails = data.hasCryptoRails;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.panel, AppColors.surface],
        ),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.gold,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verified wallet balance',
                  style: AppText.bodyLarge,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(data.walletBalanceText, style: AppText.walletValue),
          SizedBox(height: 14),
          _CryptoRailsStatus(
            label: data.cryptoRailsText,
            active: hasRails,
          ),
        ],
      ),
    );
  }
}

class _CryptoRailsStatus extends StatelessWidget {
  const _CryptoRailsStatus({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? AppColors.goldSoft : AppColors.track,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: active ? AppColors.secondary : AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

