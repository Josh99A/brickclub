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
                Container(
                  height: 170,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.panel, AppColors.surface],
                    ),
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Verified wallet balance',
                        style: AppText.bodyLarge,
                      ),
                      SizedBox(height: 10),
                      Text(data.walletBalanceText, style: AppText.walletValue),
                      SizedBox(height: 8),
                      Text(data.cryptoRailsText, style: AppText.eyebrow),
                    ],
                  ),
                ),
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

