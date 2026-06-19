part of 'brickclub_app.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.kyc,
    required this.opportunity,
    required this.investmentRepository,
    required this.onStartKyc,
  });

  final KycProfile kyc;
  final InvestmentOpportunity opportunity;
  final InvestmentRepository investmentRepository;
  final VoidCallback onStartKyc;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, 'BrickShares'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/skyline_heights.png',
                      height: 206,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Positioned(
                    top: 16,
                    left: 14,
                    child: ChoicePill(label: 'Verified docs', selected: true),
                  ),
                ],
              ),
              SizedBox(height: 26),
              Text(opportunity.displayTitle, style: AppText.detailTitle),
              Text(
                '${opportunity.assetClass} BrickShares | ${opportunity.location}',
                style: AppText.body,
              ),
              SizedBox(height: 20),
              Panel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Metric(
                            opportunity.returnText,
                            'Target return',
                            gold: true,
                          ),
                        ),
                        Expanded(
                          child: Metric(opportunity.minimumText, 'Minimum'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Metric(
                            opportunity.exitPeriod.isNotEmpty
                                ? opportunity.exitPeriod
                                : '36 mo',
                            'Liquidity',
                          ),
                        ),
                        Expanded(
                          child: Metric(opportunity.riskLevel, 'Risk level'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Panel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Funding status',
                            style: AppText.cardHeadingSmall,
                          ),
                        ),
                        Text(
                          '${opportunity.fundedPercentage.toStringAsFixed(0)}% funded',
                          style: AppText.goldBody,
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    ProgressLine(
                      value: (opportunity.fundedPercentage / 100)
                          .clamp(0.0, 1.0)
                          .toDouble(),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Supported payment options and quote expiry are shown before settlement confirmation.',
                      style: AppText.small,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              PrimaryButton(
                key: const ValueKey('invest-with-crypto'),
                label: 'Invest with crypto funding',
                onPressed: () => requireApprovedKyc(
                  context,
                  kyc,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        kyc: kyc,
                        opportunity: opportunity,
                        investmentRepository: investmentRepository,
                      ),
                    ),
                  ),
                  onStartKyc,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

