class InvestmentOpportunity {
  const InvestmentOpportunity({
    required this.id,
    required this.assetClass,
    required this.riskLevel,
    required this.paymentMethods,
    required this.title,
    required this.location,
    required this.minimumInvestment,
    required this.targetReturn,
    required this.fundedPercent,
  });

  factory InvestmentOpportunity.fromJson(Map<String, dynamic> json) {
    return InvestmentOpportunity(
      id: json['id'] as String,
      assetClass: json['assetClass'] as String? ?? 'Real Estate',
      riskLevel: json['riskLevel'] as String? ?? 'Medium',
      paymentMethods: _stringList(json['paymentMethods']),
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      minimumInvestment: (json['minimumInvestment'] as num?)?.toDouble() ?? 0,
      targetReturn: (json['targetReturn'] as num?)?.toDouble() ?? 0,
      fundedPercent: (json['fundedPercent'] as num?)?.toDouble() ?? 0,
    );
  }

  final String id;
  final String assetClass;
  final String riskLevel;
  final List<String> paymentMethods;
  final String title;
  final String location;
  final double minimumInvestment;
  final double targetReturn;
  final double fundedPercent;

  String get displayTitle => title.replaceAll(r'\n', '\n');
  String get minimumText => _formatUgx(minimumInvestment);
  String get returnText => '${targetReturn.toStringAsFixed(1)}%';
}

class MemberDashboardData {
  const MemberDashboardData({
    required this.portfolioValueUgx,
    required this.walletBalanceUgx,
    required this.yearReturnPercent,
    required this.cryptoRails,
    required this.holdings,
    required this.activity,
    required this.allocation,
    required this.chartValues,
    required this.chartLabels,
  });

  factory MemberDashboardData.empty() {
    return const MemberDashboardData(
      portfolioValueUgx: 0,
      walletBalanceUgx: 0,
      yearReturnPercent: 0,
      cryptoRails: [],
      holdings: [],
      activity: [],
      allocation: [],
      chartValues: [],
      chartLabels: [],
    );
  }

  factory MemberDashboardData.fromJson(Map<String, dynamic> json) {
    return MemberDashboardData(
      portfolioValueUgx: (json['portfolioValueUgx'] as num?)?.toDouble() ?? 0,
      walletBalanceUgx: (json['walletBalanceUgx'] as num?)?.toDouble() ?? 0,
      yearReturnPercent: (json['yearReturnPercent'] as num?)?.toDouble() ?? 0,
      cryptoRails: _stringList(json['cryptoRails']),
      holdings: _jsonList(json['holdings'], MemberHolding.fromJson),
      activity: _jsonList(json['activity'], MemberActivity.fromJson),
      allocation: _jsonList(json['allocation'], MemberAllocation.fromJson),
      chartValues: _doubleList(json['chartValues']),
      chartLabels: _stringList(json['chartLabels']),
    );
  }

  final double portfolioValueUgx;
  final double walletBalanceUgx;
  final double yearReturnPercent;
  final List<String> cryptoRails;
  final List<MemberHolding> holdings;
  final List<MemberActivity> activity;
  final List<MemberAllocation> allocation;
  final List<double> chartValues;
  final List<String> chartLabels;

  String get portfolioValueText => _formatUgx(portfolioValueUgx);
  String get walletBalanceText => _formatUgx(walletBalanceUgx);
  String get yearReturnText {
    final prefix = yearReturnPercent >= 0 ? '+' : '';
    return '$prefix${yearReturnPercent.toStringAsFixed(1)}% this year';
  }

  String get cryptoRailsText {
    if (cryptoRails.isEmpty) return 'No crypto rails enabled';
    return 'Crypto rails: ${cryptoRails.join(' / ')}';
  }

  bool get hasPortfolio => portfolioValueUgx > 0 || holdings.isNotEmpty;
}

class MemberHolding {
  const MemberHolding({
    required this.opportunityId,
    required this.title,
    required this.assetClass,
    required this.brickShares,
    required this.valueUgx,
    required this.returnPercent,
  });

  factory MemberHolding.fromJson(Map<String, dynamic> json) {
    return MemberHolding(
      opportunityId: json['opportunityId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      assetClass: json['assetClass'] as String? ?? 'BrickShares',
      brickShares: (json['brickShares'] as num?)?.toDouble() ?? 0,
      valueUgx: (json['valueUgx'] as num?)?.toDouble() ?? 0,
      returnPercent: (json['returnPercent'] as num?)?.toDouble() ?? 0,
    );
  }

  final String opportunityId;
  final String title;
  final String assetClass;
  final double brickShares;
  final double valueUgx;
  final double returnPercent;

  String get sharesText => '${brickShares.toStringAsFixed(2)} BrickShares';
  String get valueText => _formatUgx(valueUgx);
  String get returnText {
    final prefix = returnPercent >= 0 ? '+' : '';
    return '$prefix${returnPercent.toStringAsFixed(1)}%';
  }
}

class MemberActivity {
  const MemberActivity({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.status,
  });

  factory MemberActivity.fromJson(Map<String, dynamic> json) {
    return MemberActivity(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      value: json['value'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  final String title;
  final String subtitle;
  final String value;
  final String status;
}

class MemberAllocation {
  const MemberAllocation({required this.label, required this.percent});

  factory MemberAllocation.fromJson(Map<String, dynamic> json) {
    return MemberAllocation(
      label: json['label'] as String? ?? '',
      percent: (json['percent'] as num?)?.toDouble() ?? 0,
    );
  }

  final String label;
  final double percent;
}

class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.amountUgx,
    required this.paymentNetwork,
    required this.paymentAsset,
    required this.paymentWalletAddress,
    required this.paymentQrCodeUrl,
    required this.quoteAmount,
    required this.networkFee,
    required this.status,
    required this.expiresAt,
    this.transactionHash,
    this.proofUrl,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String,
      opportunityId: json['opportunityId'] as String,
      opportunityTitle: json['opportunityTitle'] as String? ?? '',
      amountUgx: (json['amountUgx'] as num?)?.toDouble() ?? 0,
      paymentNetwork: json['paymentNetwork'] as String? ?? '',
      paymentAsset: json['paymentAsset'] as String? ?? '',
      paymentWalletAddress: json['paymentWalletAddress'] as String? ?? '',
      paymentQrCodeUrl: json['paymentQrCodeUrl'] as String? ?? '',
      quoteAmount: (json['quoteAmount'] as num?)?.toDouble() ?? 0,
      networkFee: (json['networkFee'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending_payment',
      expiresAt: json['expiresAt'] as String? ?? '',
      transactionHash: json['transactionHash'] as String?,
      proofUrl: json['proofUrl'] as String?,
    );
  }

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final double amountUgx;
  final String paymentNetwork;
  final String paymentAsset;
  final String paymentWalletAddress;
  final String paymentQrCodeUrl;
  final double quoteAmount;
  final double networkFee;
  final String status;
  final String expiresAt;
  final String? transactionHash;
  final String? proofUrl;

  String get quoteText => '${quoteAmount.toStringAsFixed(2)} $paymentAsset';
  String get networkFeeText => '${networkFee.toStringAsFixed(2)} $paymentAsset';
}

class DepositProofFile {
  const DepositProofFile({
    required this.name,
    required this.bytes,
    required this.contentType,
  });

  final String name;
  final List<int> bytes;
  final String contentType;
}

class PurchaseRequest {
  const PurchaseRequest({
    required this.opportunityId,
    required this.amountUgx,
    this.paymentAsset = 'USDT',
  });

  final String opportunityId;
  final double amountUgx;
  final String paymentAsset;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList(growable: false);
}

List<double> _doubleList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<num>().map((item) => item.toDouble()).toList();
}

List<T> _jsonList<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

String _formatUgx(double value) {
  if (value >= 1000000) {
    final millions = value / 1000000;
    return 'UGX ${millions.toStringAsFixed(millions >= 10 ? 0 : 1)}M';
  }
  if (value >= 1000) {
    final thousands = value / 1000;
    return 'UGX ${thousands.toStringAsFixed(thousands >= 10 ? 0 : 1)}K';
  }
  return 'UGX ${value.toStringAsFixed(0)}';
}
