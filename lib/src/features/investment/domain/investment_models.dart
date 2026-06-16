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
