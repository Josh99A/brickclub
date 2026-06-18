part of 'brickclub_app.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.order});

  final PurchaseOrder order;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
            child: Column(
              children: [
                Container(
                  width: 128,
                  height: 128,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.track,
                    border: Border.all(color: AppColors.gold),
                    shape: BoxShape.circle,
                  ),
                  child: Text('OK', style: AppText.goldMetricSmall),
                ),
                SizedBox(height: 44),
                Text('Proof submitted', style: AppText.h1),
                SizedBox(height: 12),
                Text(
                  'Your proof of payment is awaiting admin verification. '
                  'We will notify you after review.',
                  textAlign: TextAlign.center,
                  style: AppText.bodyLarge,
                ),
                SizedBox(height: 38),
                Panel(
                  child: SizedBox(
                    height: 84,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Settlement status',
                            style: AppText.bodyLarge,
                          ),
                        ),
                        Text(order.status, style: AppText.warning),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 62),
                PrimaryButton(
                  key: const ValueKey('view-portfolio'),
                  label: 'View portfolio',
                  onPressed: () => context.go('/portfolio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

