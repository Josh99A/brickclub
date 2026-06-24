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
    this.description = '',
    this.category = 'realEstate',
    this.assetType = '',
    this.images = const [],
    this.purchasePrice = 0,
    this.fundingTarget = 0,
    this.amountFunded = 0,
    this.pricePerShare = 0,
    this.totalShares = 0,
    this.availableShares = 0,
    this.expectedAnnualYield = 0,
    this.projectedNetYield = 0,
    this.strategy = 'capitalGrowth',
    this.exitPeriod = '',
    this.documents = const [],
    this.status = 'available',
    this.regulationNote = '',
    this.currentAssetValue = 0,
  });

  factory InvestmentOpportunity.fromJson(Map<String, dynamic> json) {
    final purchasePrice = (json['purchasePrice'] as num?)?.toDouble() ?? 0;
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
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'realEstate',
      assetType: json['assetType'] as String? ?? '',
      images: _stringList(json['images']),
      purchasePrice: purchasePrice,
      fundingTarget: (json['fundingTarget'] as num?)?.toDouble() ?? 0,
      amountFunded: (json['amountFunded'] as num?)?.toDouble() ?? 0,
      pricePerShare: (json['pricePerShare'] as num?)?.toDouble() ?? 0,
      totalShares: (json['totalShares'] as num?)?.toDouble() ?? 0,
      availableShares: (json['availableShares'] as num?)?.toDouble() ?? 0,
      expectedAnnualYield:
          (json['expectedAnnualYield'] as num?)?.toDouble() ?? 0,
      projectedNetYield: (json['projectedNetYield'] as num?)?.toDouble() ?? 0,
      strategy: json['strategy'] as String? ?? 'capitalGrowth',
      exitPeriod: json['exitPeriod'] as String? ?? '',
      documents: _stringList(json['documents']),
      status: json['status'] as String? ?? 'available',
      regulationNote: json['regulationNote'] as String? ?? '',
      currentAssetValue:
          (json['currentAssetValue'] as num?)?.toDouble() ?? purchasePrice,
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
  final String description;
  final String category;
  final String assetType;
  final List<String> images;
  final double purchasePrice;
  final double fundingTarget;
  final double amountFunded;
  final double pricePerShare;
  final double totalShares;
  final double availableShares;
  final double expectedAnnualYield;
  final double projectedNetYield;
  final String strategy;
  final String exitPeriod;
  final List<String> documents;
  final String status;
  final String regulationNote;
  final double currentAssetValue;

  String get displayTitle => title.replaceAll(r'\n', '\n');
  String get minimumText => _formatUsd(minimumInvestment);
  String get returnText => '${targetReturn.toStringAsFixed(1)}%';

  /// Percentage of the funding target raised so far. Falls back to the stored
  /// [fundedPercent] when no funding target is configured.
  double get fundedPercentage => fundingTarget > 0
      ? (amountFunded / fundingTarget) * 100
      : fundedPercent;

  /// BrickShares a member would receive for [amountUsd]. Guards divide-by-zero.
  double sharesForAmount(double amountUsd) =>
      pricePerShare > 0 ? amountUsd / pricePerShare : 0;

  /// Ownership percentage of the underlying asset for [amountUsd].
  double ownershipForAmount(double amountUsd) =>
      purchasePrice > 0 ? (amountUsd / purchasePrice) * 100 : 0;
}

class MemberDashboardData {
  const MemberDashboardData({
    required this.portfolioValueUsd,
    required this.walletBalanceUsd,
    required this.yearReturnPercent,
    required this.cryptoRails,
    required this.holdings,
    required this.activity,
    required this.allocation,
    required this.chartValues,
    required this.chartLabels,
    this.totalInvested = 0,
    this.totalCurrentValue = 0,
    this.totalDividends = 0,
    this.totalProfitLoss = 0,
    this.overallReturnPercentage = 0,
  });

  factory MemberDashboardData.empty() {
    return const MemberDashboardData(
      portfolioValueUsd: 0,
      walletBalanceUsd: 0,
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
    final invested = (json['totalInvested'] as num?)?.toDouble() ?? 0;
    final currentValue =
        (json['totalCurrentValue'] as num?)?.toDouble() ??
        (json['portfolioValueUsd'] as num?)?.toDouble() ??
        0;
    return MemberDashboardData(
      portfolioValueUsd: (json['portfolioValueUsd'] as num?)?.toDouble() ?? 0,
      walletBalanceUsd: (json['walletBalanceUsd'] as num?)?.toDouble() ?? 0,
      yearReturnPercent: (json['yearReturnPercent'] as num?)?.toDouble() ?? 0,
      cryptoRails: _stringList(json['cryptoRails']),
      holdings: _jsonList(json['holdings'], MemberHolding.fromJson),
      activity: _jsonList(json['activity'], MemberActivity.fromJson),
      allocation: _jsonList(json['allocation'], MemberAllocation.fromJson),
      chartValues: _doubleList(json['chartValues']),
      chartLabels: _stringList(json['chartLabels']),
      totalInvested: invested,
      totalCurrentValue: currentValue,
      totalDividends: (json['totalDividends'] as num?)?.toDouble() ?? 0,
      totalProfitLoss: (json['totalProfitLoss'] as num?)?.toDouble() ?? 0,
      overallReturnPercentage:
          (json['overallReturnPercentage'] as num?)?.toDouble() ?? 0,
    );
  }

  final double portfolioValueUsd;
  final double walletBalanceUsd;
  final double yearReturnPercent;
  final List<String> cryptoRails;
  final List<MemberHolding> holdings;
  final List<MemberActivity> activity;
  final List<MemberAllocation> allocation;
  final List<double> chartValues;
  final List<String> chartLabels;
  final double totalInvested;
  final double totalCurrentValue;
  final double totalDividends;
  final double totalProfitLoss;
  final double overallReturnPercentage;

  String get portfolioValueText => _formatUsd(portfolioValueUsd);
  String get walletBalanceText => _formatUsd(walletBalanceUsd);
  String get totalInvestedText => _formatUsd(totalInvested);
  String get totalCurrentValueText => _formatUsd(totalCurrentValue);
  String get totalDividendsText => _formatUsd(totalDividends);
  String get totalProfitLossText {
    final prefix = totalProfitLoss >= 0 ? '+' : '-';
    return '$prefix${_formatUsd(totalProfitLoss.abs())}';
  }

  String get overallReturnText {
    final prefix = overallReturnPercentage >= 0 ? '+' : '';
    return '$prefix${overallReturnPercentage.toStringAsFixed(1)}%';
  }

  String get yearReturnText {
    final prefix = yearReturnPercent >= 0 ? '+' : '';
    return '$prefix${yearReturnPercent.toStringAsFixed(1)}% this year';
  }

  bool get hasCryptoRails => cryptoRails.isNotEmpty;

  String get cryptoRailsText {
    if (cryptoRails.isEmpty) return 'No crypto rails enabled';
    return cryptoRails.join(' · ');
  }

  bool get hasPortfolio => portfolioValueUsd > 0 || holdings.isNotEmpty;
}

class MemberHolding {
  const MemberHolding({
    required this.opportunityId,
    required this.title,
    required this.assetClass,
    required this.brickShares,
    required this.valueUsd,
    required this.returnPercent,
    this.amountInvested = 0,
    this.sharesOwned = 0,
    this.ownershipPercentage = 0,
    this.currentValue = 0,
    this.dividendsReceived = 0,
    this.profitLoss = 0,
    this.returnPercentage = 0,
    this.assetTitle = '',
    this.assetImageUrl = '',
    this.assetCategory = '',
    this.assetStrategy = '',
    this.assetStatus = 'available',
  });

  factory MemberHolding.fromJson(Map<String, dynamic> json) {
    final valueUsd =
        (json['valueUsd'] as num?)?.toDouble() ??
        (json['currentValue'] as num?)?.toDouble() ??
        0;
    return MemberHolding(
      opportunityId:
          json['opportunityId'] as String? ?? json['assetId'] as String? ?? '',
      title: json['title'] as String? ?? json['assetTitle'] as String? ?? '',
      assetClass:
          json['assetClass'] as String? ??
          json['assetCategory'] as String? ??
          'BrickShares',
      brickShares:
          (json['brickShares'] as num?)?.toDouble() ??
          (json['sharesOwned'] as num?)?.toDouble() ??
          0,
      valueUsd: valueUsd,
      returnPercent:
          (json['returnPercent'] as num?)?.toDouble() ??
          (json['returnPercentage'] as num?)?.toDouble() ??
          0,
      amountInvested: (json['amountInvested'] as num?)?.toDouble() ?? 0,
      sharesOwned: (json['sharesOwned'] as num?)?.toDouble() ?? 0,
      ownershipPercentage:
          (json['ownershipPercentage'] as num?)?.toDouble() ?? 0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? valueUsd,
      dividendsReceived: (json['dividendsReceived'] as num?)?.toDouble() ?? 0,
      profitLoss: (json['profitLoss'] as num?)?.toDouble() ?? 0,
      returnPercentage: (json['returnPercentage'] as num?)?.toDouble() ?? 0,
      assetTitle: json['assetTitle'] as String? ?? json['title'] as String? ?? '',
      assetImageUrl: json['assetImageUrl'] as String? ?? '',
      assetCategory: json['assetCategory'] as String? ?? '',
      assetStrategy: json['assetStrategy'] as String? ?? '',
      assetStatus: json['assetStatus'] as String? ?? 'available',
    );
  }

  final String opportunityId;
  final String title;
  final String assetClass;
  final double brickShares;
  final double valueUsd;
  final double returnPercent;
  final double amountInvested;
  final double sharesOwned;
  final double ownershipPercentage;
  final double currentValue;
  final double dividendsReceived;
  final double profitLoss;
  final double returnPercentage;
  final String assetTitle;
  final String assetImageUrl;
  final String assetCategory;
  final String assetStrategy;
  final String assetStatus;

  String get sharesText => '${brickShares.toStringAsFixed(2)} BrickShares';
  String get valueText => _formatUsd(valueUsd);
  String get amountInvestedText => _formatUsd(amountInvested);
  String get currentValueText => _formatUsd(currentValue);
  String get ownershipText => '${ownershipPercentage.toStringAsFixed(2)}%';
  String get profitLossText {
    final prefix = profitLoss >= 0 ? '+' : '-';
    return '$prefix${_formatUsd(profitLoss.abs())}';
  }

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

class MemberNotification {
  const MemberNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.data = const {},
  });

  factory MemberNotification.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = <String, String>{};
    if (rawData is Map) {
      rawData.forEach((key, value) {
        data['$key'] = '${value ?? ''}';
      });
    }
    return MemberNotification(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      data: data,
    );
  }

  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final String createdAt;
  final Map<String, String> data;

  bool get isUnread => !read;
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
    required this.amountUsd,
    required this.paymentNetwork,
    required this.paymentAsset,
    required this.paymentWalletAddress,
    required this.paymentQrCodeUrl,
    required this.quoteAmount,
    required this.networkFee,
    required this.status,
    required this.expiresAt,
    this.paymentType = 'crypto',
    this.paymentAccountDetails = const [],
    this.transactionHash,
    this.proofUrl,
    this.sharesExpected = 0,
    this.ownershipPercentage = 0,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String,
      opportunityId: json['opportunityId'] as String,
      opportunityTitle: json['opportunityTitle'] as String? ?? '',
      amountUsd: (json['amountUsd'] as num?)?.toDouble() ?? 0,
      paymentNetwork:
          json['paymentNetwork'] as String? ??
          json['cryptoNetwork'] as String? ??
          '',
      paymentAsset:
          json['paymentAsset'] as String? ??
          json['cryptoCurrency'] as String? ??
          '',
      paymentWalletAddress: json['paymentWalletAddress'] as String? ?? '',
      paymentQrCodeUrl: json['paymentQrCodeUrl'] as String? ?? '',
      paymentType: json['paymentType'] as String? ?? 'crypto',
      paymentAccountDetails: _jsonList(
        json['paymentAccountDetails'],
        OrderPaymentField.fromJson,
      ),
      quoteAmount:
          (json['quoteAmount'] as num?)?.toDouble() ??
          (json['cryptoAmountExpected'] as num?)?.toDouble() ??
          0,
      networkFee: (json['networkFee'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending_payment',
      expiresAt: json['expiresAt'] as String? ?? '',
      transactionHash: json['transactionHash'] as String?,
      proofUrl: json['proofUrl'] as String? ?? json['proofImageUrl'] as String?,
      sharesExpected: (json['sharesExpected'] as num?)?.toDouble() ?? 0,
      ownershipPercentage:
          (json['ownershipPercentage'] as num?)?.toDouble() ?? 0,
      approvedAt: json['approvedAt'] as String?,
      approvedBy: json['approvedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final double amountUsd;
  final String paymentNetwork;
  final String paymentAsset;
  final String paymentWalletAddress;
  final String paymentQrCodeUrl;
  final String paymentType;
  final List<OrderPaymentField> paymentAccountDetails;
  final double quoteAmount;
  final double networkFee;
  final String status;
  final String expiresAt;
  final String? transactionHash;
  final String? proofUrl;
  final double sharesExpected;
  final double ownershipPercentage;
  final String? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;

  bool get isCrypto => paymentType == 'crypto';

  String get quoteText => '${quoteAmount.toStringAsFixed(2)} $paymentAsset';
  String get networkFeeText => '${networkFee.toStringAsFixed(2)} $paymentAsset';

  /// Human-readable status matching the upgraded crypto order lifecycle.
  String get statusLabel => switch (status) {
    'pending_payment' => 'Pending payment',
    'proof_submitted' => 'Submitted for review',
    'deposit_verified' => 'Approved',
    'deposit_rejected' => 'Rejected',
    'expired' => 'Expired',
    _ => status,
  };
}

/// A label/value line of deposit instructions for a non-crypto order, snapshotted
/// from the payment option at order time (e.g. "IBAN": "GB...").
class OrderPaymentField {
  const OrderPaymentField({required this.label, required this.value});

  factory OrderPaymentField.fromJson(Map<String, dynamic> json) {
    return OrderPaymentField(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  final String label;
  final String value;
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
    required this.amountUsd,
    this.paymentAsset = 'USDT',
  });

  final String opportunityId;
  final double amountUsd;
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

String _formatUsd(double value) {
  if (value >= 1000000) {
    final millions = value / 1000000;
    return '\$${millions.toStringAsFixed(millions >= 10 ? 0 : 1)}M';
  }
  if (value >= 1000) {
    final thousands = value / 1000;
    return '\$${thousands.toStringAsFixed(thousands >= 10 ? 0 : 1)}K';
  }
  return '\$${value.toStringAsFixed(0)}';
}
