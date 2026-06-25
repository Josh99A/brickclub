part of 'brickclub_app.dart';

/// Lock spendable wallet cash into one of an asset's fixed-return plans. The
/// member enters an amount (which selects a band), picks a lock duration, sees
/// the projected profit + maturity date, and confirms — debiting their wallet
/// and creating the plan server-side.
class InvestPlanScreen extends StatefulWidget {
  const InvestPlanScreen({
    super.key,
    required this.opportunity,
    required this.investmentRepository,
  });

  final InvestmentOpportunity opportunity;
  final InvestmentRepository investmentRepository;

  @override
  State<InvestPlanScreen> createState() => _InvestPlanScreenState();
}

class _InvestPlanScreenState extends State<InvestPlanScreen> {
  static const _durations = [
    ('week', '1 week'),
    ('month', '1 month'),
    ('year', '1 year'),
  ];

  late final TextEditingController _amountController;
  String _durationKey = 'week';
  bool _submitting = true; // until the wallet balance loads
  double _walletBalance = 0;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.opportunity.bandsMinimum > 0
          ? widget.opportunity.bandsMinimum.toStringAsFixed(0)
          : '',
    );
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final data = await widget.investmentRepository.loadMemberDashboard();
      if (!mounted) return;
      setState(() {
        _walletBalance = data.walletBalanceUsd;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _submitting = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount {
    final normalized = _amountController.text.replaceAll(',', '').trim();
    return double.tryParse(normalized) ?? 0;
  }

  InvestmentBand? get _band => widget.opportunity.bandForAmount(_amount);

  double get _ratePercent => _band?.rateForDuration(_durationKey) ?? 0;
  double get _profit => _amount * _ratePercent / 100;
  double get _payout => _amount + _profit;

  DateTime get _maturity {
    final days = switch (_durationKey) {
      'week' => 7,
      'month' => 30,
      'year' => 365,
      _ => 0,
    };
    return DateTime.now().add(Duration(days: days));
  }

  bool get _canConfirm =>
      !_submitting &&
      _band != null &&
      _amount > 0 &&
      _amount <= _walletBalance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final opportunity = widget.opportunity;
    final hasFunds = _amount <= _walletBalance;

    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, l10n.investPlanTitle),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!opportunity.hasInvestmentPlans)
                Panel(
                  child: Text(
                    l10n.investPlanNonePanel,
                    style: AppText.body,
                  ),
                )
              else ...[
                _WalletAvailableCard(
                  balanceText: _formatUsdCompact(_walletBalance),
                  loadFailed: _loadFailed,
                ),
                SizedBox(height: 18),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opportunity.displayTitle, style: AppText.cardHeading),
                      SizedBox(height: 4),
                      Text(opportunity.location, style: AppText.body),
                      SizedBox(height: 16),
                      FieldLabel(l10n.investPlanAmount),
                      SizedBox(height: 8),
                      AppTextField(
                        key: const ValueKey('invest-amount'),
                        controller: _amountController,
                        hintText: l10n.investPlanAmountHint(
                          _formatUsdCompact(opportunity.bandsMinimum),
                          _formatUsdCompact(opportunity.bandsMaximum),
                        ),
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payments_outlined,
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _band == null
                            ? l10n.investPlanOutOfRange(
                                _formatUsdCompact(opportunity.bandsMinimum),
                                _formatUsdCompact(opportunity.bandsMaximum),
                              )
                            : !hasFunds
                            ? l10n.investPlanInsufficient
                            : l10n.investPlanBandApplied(_band!.rangeText),
                        style: (_band == null || !hasFunds)
                            ? AppText.warning
                            : AppText.small,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                FieldLabel(l10n.investPlanDuration),
                SizedBox(height: 10),
                Row(
                  children: [
                    for (final (key, label) in _durations) ...[
                      Expanded(
                        child: _DurationCard(
                          label: label,
                          rateText:
                              '${_rateFor(key).toStringAsFixed(_rateFor(key) % 1 == 0 ? 0 : 1)}%',
                          selected: _durationKey == key,
                          onTap: () => setState(() => _durationKey = key),
                        ),
                      ),
                      if (key != 'year') SizedBox(width: 10),
                    ],
                  ],
                ),
                SizedBox(height: 18),
                Panel(
                  child: Column(
                    children: [
                      QuoteRow(
                        l10n.investPlanPrincipal,
                        _formatUsdCompact(_amount),
                      ),
                      QuoteRow(
                        l10n.investPlanRate,
                        '${_ratePercent.toStringAsFixed(_ratePercent % 1 == 0 ? 0 : 1)}%',
                      ),
                      QuoteRow(
                        l10n.investPlanProfit,
                        '+${_formatUsdCompact(_profit)}',
                      ),
                      QuoteRow(
                        l10n.investPlanPayout,
                        _formatUsdCompact(_payout),
                      ),
                      QuoteRow(
                        l10n.investPlanMaturity,
                        _formatDate(_maturity),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14),
                Text(l10n.investPlanDisclaimer, style: AppText.small),
                SizedBox(height: 28),
                PrimaryButton(
                  key: const ValueKey('confirm-investment'),
                  label: _submitting
                      ? l10n.commonSubmitting
                      : l10n.investPlanConfirm,
                  onPressed: _canConfirm ? _confirm : null,
                ),
                SizedBox(height: 14),
                SecondaryButton(
                  label: l10n.commonCancel,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _rateFor(String key) => _band?.rateForDuration(key) ?? 0;

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _submitting = true);
    try {
      final result = await widget.investmentRepository.createInvestmentPlan(
        assetId: widget.opportunity.id,
        amountUsd: _amount,
        durationKey: _durationKey,
      );
      if (!mounted) return;
      showMessage(
        context,
        l10n.investPlanSuccess(
          _formatUsdCompact(result.payoutUsd),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        showMessage(context, _friendlyUnexpectedMessage(error, l10n));
        setState(() => _submitting = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}

class _WalletAvailableCard extends StatelessWidget {
  const _WalletAvailableCard({
    required this.balanceText,
    required this.loadFailed,
  });

  final String balanceText;
  final bool loadFailed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: AppColors.gold),
          SizedBox(width: 12),
          Expanded(
            child: Text(l10n.investPlanAvailable, style: AppText.body),
          ),
          Text(
            loadFailed ? '—' : balanceText,
            style: AppText.cardHeading,
          ),
        ],
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  const _DurationCard({
    required this.label,
    required this.rateText,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String rateText;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldSoft : AppColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              rateText,
              style: TextStyle(
                color: selected ? AppColors.gold : AppColors.secondary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(label, style: AppText.small, maxLines: 1),
          ],
        ),
      ),
    );
  }
}
