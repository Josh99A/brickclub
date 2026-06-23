class AdminDashboardData {
  const AdminDashboardData({
    required this.users,
    required this.assets,
    required this.cryptoPaymentOptions,
    required this.depositRequests,
    required this.supportTickets,
    required this.withdrawalPolicy,
    required this.referralPolicy,
    this.notifications = const [],
    this.kycProfiles = const [],
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      users: _list(json['users'], AdminUser.fromJson),
      assets: _list(json['assets'], AdminAsset.fromJson),
      cryptoPaymentOptions: _list(
        json['cryptoPaymentOptions'],
        CryptoPaymentOption.fromJson,
      ),
      depositRequests: _list(
        json['depositRequests'],
        AdminDepositRequest.fromJson,
      ),
      supportTickets: _list(
        json['supportTickets'],
        AdminSupportTicket.fromJson,
      ),
      notifications: _list(json['notifications'], AdminNotification.fromJson),
      withdrawalPolicy: WithdrawalPolicy.fromJson(
        Map<String, dynamic>.from(json['withdrawalPolicy'] as Map? ?? {}),
      ),
      referralPolicy: ReferralPolicy.fromJson(
        Map<String, dynamic>.from(json['referralPolicy'] as Map? ?? {}),
      ),
      kycProfiles: _list(json['kycProfiles'], AdminKycProfile.fromJson),
    );
  }

  final List<AdminUser> users;
  final List<AdminAsset> assets;
  final List<CryptoPaymentOption> cryptoPaymentOptions;
  final List<AdminDepositRequest> depositRequests;
  final List<AdminSupportTicket> supportTickets;
  final List<AdminNotification> notifications;
  final WithdrawalPolicy withdrawalPolicy;
  final ReferralPolicy referralPolicy;
  final List<AdminKycProfile> kycProfiles;

  int get unreadNotificationCount =>
      notifications.where((notification) => notification.isUnread).length;
}

class AdminNotification {
  const AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final String createdAt;

  bool get isUnread => !read;
}

class AdminUser {
  const AdminUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.disabled,
    required this.emailVerified,
    required this.admin,
    required this.createdAt,
    required this.lastSignInAt,
    this.phoneNumber = '',
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      uid: json['uid'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      disabled: json['disabled'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool? ?? false,
      admin: json['admin'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      lastSignInAt: json['lastSignInAt'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }

  final String uid;
  final String email;
  final String? displayName;
  final bool disabled;
  final bool emailVerified;
  final bool admin;
  final String? createdAt;
  final String? lastSignInAt;
  final String phoneNumber;
}

class AdminUserDetail {
  const AdminUserDetail({
    required this.user,
    required this.kyc,
    required this.portfolio,
    required this.orders,
    required this.wallet,
  });

  factory AdminUserDetail.fromJson(Map<String, dynamic> json) {
    final kycJson = json['kyc'];
    return AdminUserDetail(
      user: AdminUser.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? {}),
      ),
      kyc: kycJson is Map
          ? AdminUserKyc.fromJson(Map<String, dynamic>.from(kycJson))
          : null,
      portfolio: AdminUserPortfolio.fromJson(
        Map<String, dynamic>.from(json['portfolio'] as Map? ?? {}),
      ),
      orders: _list(json['orders'], AdminUserOrder.fromJson),
      wallet: AdminUserWallet.fromJson(
        Map<String, dynamic>.from(json['wallet'] as Map? ?? {}),
      ),
    );
  }

  final AdminUser user;
  final AdminUserKyc? kyc;
  final AdminUserPortfolio portfolio;
  final List<AdminUserOrder> orders;
  final AdminUserWallet wallet;
}

class AdminUserWallet {
  const AdminUserWallet({
    required this.balanceUsd,
    required this.transactions,
  });

  factory AdminUserWallet.fromJson(Map<String, dynamic> json) {
    return AdminUserWallet(
      balanceUsd: (json['balanceUsd'] as num?)?.toDouble() ?? 0,
      transactions: _list(
        json['transactions'],
        AdminWalletTransaction.fromJson,
      ),
    );
  }

  final double balanceUsd;
  final List<AdminWalletTransaction> transactions;
}

class AdminWalletTransaction {
  const AdminWalletTransaction({
    required this.id,
    required this.type,
    required this.amountUsd,
    required this.balanceAfter,
    required this.reason,
    required this.createdAt,
  });

  factory AdminWalletTransaction.fromJson(Map<String, dynamic> json) {
    return AdminWalletTransaction(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      amountUsd: (json['amountUsd'] as num?)?.toDouble() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  final String id;
  final String type;
  final double amountUsd;
  final double balanceAfter;
  final String reason;
  final String createdAt;

  bool get isCredit => type == 'credit';
}

class AdminUserKyc {
  const AdminUserKyc({
    required this.fullLegalName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.status,
    required this.rejectionReason,
    required this.phoneVerified,
    required this.governmentIdUrl,
    required this.selfieUrl,
    required this.addressProofUrl,
    required this.submittedAt,
  });

  factory AdminUserKyc.fromJson(Map<String, dynamic> json) {
    return AdminUserKyc(
      fullLegalName: json['fullLegalName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      status: json['status'] as String? ?? 'notStarted',
      rejectionReason: json['rejectionReason'] as String? ?? '',
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      governmentIdUrl: json['governmentIdUrl'] as String? ?? '',
      selfieUrl: json['selfieUrl'] as String? ?? '',
      addressProofUrl: json['addressProofUrl'] as String? ?? '',
      submittedAt: json['submittedAt'] as String? ?? '',
    );
  }

  final String fullLegalName;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  final String status;
  final String rejectionReason;
  final bool phoneVerified;
  final String governmentIdUrl;
  final String selfieUrl;
  final String addressProofUrl;
  final String submittedAt;

  String get statusLabel => switch (status) {
    'notStarted' => 'Not started',
    'inProgress' => 'In progress',
    'submitted' => 'Submitted',
    'approved' => 'Approved',
    'rejected' => 'Rejected',
    _ => status,
  };
}

class AdminUserPortfolio {
  const AdminUserPortfolio({
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.totalDividends,
    required this.totalProfitLoss,
    required this.overallReturnPercentage,
    required this.holdings,
  });

  factory AdminUserPortfolio.fromJson(Map<String, dynamic> json) {
    return AdminUserPortfolio(
      totalInvested: (json['totalInvested'] as num?)?.toDouble() ?? 0,
      totalCurrentValue: (json['totalCurrentValue'] as num?)?.toDouble() ?? 0,
      totalDividends: (json['totalDividends'] as num?)?.toDouble() ?? 0,
      totalProfitLoss: (json['totalProfitLoss'] as num?)?.toDouble() ?? 0,
      overallReturnPercentage:
          (json['overallReturnPercentage'] as num?)?.toDouble() ?? 0,
      holdings: _list(json['holdings'], AdminUserHolding.fromJson),
    );
  }

  final double totalInvested;
  final double totalCurrentValue;
  final double totalDividends;
  final double totalProfitLoss;
  final double overallReturnPercentage;
  final List<AdminUserHolding> holdings;
}

class AdminUserHolding {
  const AdminUserHolding({
    required this.assetId,
    required this.assetTitle,
    required this.amountInvested,
    required this.currentValue,
    required this.profitLoss,
    required this.returnPercentage,
  });

  factory AdminUserHolding.fromJson(Map<String, dynamic> json) {
    return AdminUserHolding(
      assetId: json['assetId'] as String? ?? '',
      assetTitle: json['assetTitle'] as String? ?? '',
      amountInvested: (json['amountInvested'] as num?)?.toDouble() ?? 0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      profitLoss: (json['profitLoss'] as num?)?.toDouble() ?? 0,
      returnPercentage: (json['returnPercentage'] as num?)?.toDouble() ?? 0,
    );
  }

  final String assetId;
  final String assetTitle;
  final double amountInvested;
  final double currentValue;
  final double profitLoss;
  final double returnPercentage;
}

class AdminUserOrder {
  const AdminUserOrder({
    required this.id,
    required this.opportunityTitle,
    required this.amountUsd,
    required this.status,
    required this.updatedAt,
  });

  factory AdminUserOrder.fromJson(Map<String, dynamic> json) {
    return AdminUserOrder(
      id: json['id'] as String? ?? '',
      opportunityTitle: json['opportunityTitle'] as String? ?? '',
      amountUsd: (json['amountUsd'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  final String id;
  final String opportunityTitle;
  final double amountUsd;
  final String status;
  final String updatedAt;
}

class AdminAsset {
  const AdminAsset({
    required this.id,
    required this.title,
    required this.location,
    required this.type,
    required this.fundedPercent,
    required this.reviewStatus,
    required this.publishedStatus,
    this.description = '',
    this.category = 'realEstate',
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
    this.riskLevel = 'balanced',
    this.exitPeriod = '',
    this.status = 'available',
    this.regulationNote = '',
    this.currentAssetValue = 0,
    this.minimumInvestment = 50,
  });

  factory AdminAsset.empty() {
    return const AdminAsset(
      id: '',
      title: '',
      location: '',
      type: 'Real estate',
      fundedPercent: 0,
      reviewStatus: 'Pending',
      publishedStatus: 'Draft',
    );
  }

  factory AdminAsset.fromJson(Map<String, dynamic> json) {
    final purchasePrice = (json['purchasePrice'] as num?)?.toDouble() ?? 0;
    return AdminAsset(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      type: json['type'] as String? ?? '',
      fundedPercent: (json['fundedPercent'] as num?)?.toDouble() ?? 0,
      reviewStatus: json['reviewStatus'] as String? ?? 'Pending',
      publishedStatus: json['publishedStatus'] as String? ?? 'Draft',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'realEstate',
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
      riskLevel: json['riskLevel'] as String? ?? 'balanced',
      exitPeriod: json['exitPeriod'] as String? ?? '',
      status: json['status'] as String? ?? 'available',
      regulationNote: json['regulationNote'] as String? ?? '',
      currentAssetValue:
          (json['currentAssetValue'] as num?)?.toDouble() ?? purchasePrice,
      minimumInvestment: (json['minimumInvestment'] as num?)?.toDouble() ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'location': location,
      'type': type,
      'fundedPercent': fundedPercent,
      'reviewStatus': reviewStatus,
      'publishedStatus': publishedStatus,
      'description': description,
      'category': category,
      'images': images,
      'assetType': type,
      'purchasePrice': purchasePrice,
      'fundingTarget': fundingTarget,
      'amountFunded': amountFunded,
      'pricePerShare': pricePerShare,
      'totalShares': totalShares,
      'availableShares': availableShares,
      'expectedAnnualYield': expectedAnnualYield,
      'projectedNetYield': projectedNetYield,
      'strategy': strategy,
      'riskLevel': riskLevel,
      'exitPeriod': exitPeriod,
      'status': status,
      'regulationNote': regulationNote,
      'currentAssetValue': currentAssetValue,
      'minimumInvestment': minimumInvestment,
    };
  }

  AdminAsset copyWith({
    String? title,
    String? location,
    String? type,
    double? fundedPercent,
    String? reviewStatus,
    String? publishedStatus,
    String? description,
    String? category,
    List<String>? images,
    double? purchasePrice,
    double? fundingTarget,
    double? amountFunded,
    double? pricePerShare,
    double? totalShares,
    double? availableShares,
    double? expectedAnnualYield,
    double? projectedNetYield,
    String? strategy,
    String? riskLevel,
    String? exitPeriod,
    String? status,
    String? regulationNote,
    double? currentAssetValue,
    double? minimumInvestment,
  }) {
    return AdminAsset(
      id: id,
      title: title ?? this.title,
      location: location ?? this.location,
      type: type ?? this.type,
      fundedPercent: fundedPercent ?? this.fundedPercent,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      publishedStatus: publishedStatus ?? this.publishedStatus,
      description: description ?? this.description,
      category: category ?? this.category,
      images: images ?? this.images,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      fundingTarget: fundingTarget ?? this.fundingTarget,
      amountFunded: amountFunded ?? this.amountFunded,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      totalShares: totalShares ?? this.totalShares,
      availableShares: availableShares ?? this.availableShares,
      expectedAnnualYield: expectedAnnualYield ?? this.expectedAnnualYield,
      projectedNetYield: projectedNetYield ?? this.projectedNetYield,
      strategy: strategy ?? this.strategy,
      riskLevel: riskLevel ?? this.riskLevel,
      exitPeriod: exitPeriod ?? this.exitPeriod,
      status: status ?? this.status,
      regulationNote: regulationNote ?? this.regulationNote,
      currentAssetValue: currentAssetValue ?? this.currentAssetValue,
      minimumInvestment: minimumInvestment ?? this.minimumInvestment,
    );
  }

  final String id;
  final String title;
  final String location;
  final String type;
  final double fundedPercent;
  final String reviewStatus;
  final String publishedStatus;
  final String description;
  final String category;
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
  final String riskLevel;
  final String exitPeriod;
  final String status;
  final String regulationNote;
  final double currentAssetValue;
  final double minimumInvestment;
}

class CryptoPaymentOption {
  const CryptoPaymentOption({
    required this.id,
    required this.network,
    required this.assetSymbol,
    required this.walletAddress,
    required this.qrCodeUrl,
    required this.enabled,
    required this.minimumAmount,
  });

  factory CryptoPaymentOption.empty() {
    return const CryptoPaymentOption(
      id: '',
      network: 'Tron',
      assetSymbol: 'USDT',
      walletAddress: '',
      qrCodeUrl: '',
      enabled: true,
      minimumAmount: 0,
    );
  }

  factory CryptoPaymentOption.fromJson(Map<String, dynamic> json) {
    return CryptoPaymentOption(
      id: json['id'] as String,
      network: json['network'] as String? ?? '',
      assetSymbol: json['assetSymbol'] as String? ?? '',
      walletAddress: json['walletAddress'] as String? ?? '',
      qrCodeUrl: json['qrCodeUrl'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      minimumAmount: (json['minimumAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'network': network,
      'assetSymbol': assetSymbol,
      'walletAddress': walletAddress,
      'qrCodeUrl': qrCodeUrl,
      'enabled': enabled,
      'minimumAmount': minimumAmount,
    };
  }

  final String id;
  final String network;
  final String assetSymbol;
  final String walletAddress;
  final String qrCodeUrl;
  final bool enabled;
  final double minimumAmount;
}

class AdminUploadFile {
  const AdminUploadFile({
    required this.name,
    required this.bytes,
    required this.contentType,
  });

  final String name;
  final List<int> bytes;
  final String contentType;
}

class AdminDepositRequest {
  const AdminDepositRequest({
    required this.id,
    required this.uid,
    required this.opportunityTitle,
    required this.amountUsd,
    required this.paymentNetwork,
    required this.paymentAsset,
    required this.paymentWalletAddress,
    required this.transactionHash,
    required this.proofUrl,
    required this.status,
  });

  factory AdminDepositRequest.fromJson(Map<String, dynamic> json) {
    return AdminDepositRequest(
      id: json['id'] as String,
      uid: json['uid'] as String? ?? '',
      opportunityTitle: json['opportunityTitle'] as String? ?? '',
      amountUsd: (json['amountUsd'] as num?)?.toDouble() ?? 0,
      paymentNetwork: json['paymentNetwork'] as String? ?? '',
      paymentAsset: json['paymentAsset'] as String? ?? '',
      paymentWalletAddress: json['paymentWalletAddress'] as String? ?? '',
      transactionHash: json['transactionHash'] as String? ?? '',
      proofUrl: json['proofUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'pending_payment',
    );
  }

  final String id;
  final String uid;
  final String opportunityTitle;
  final double amountUsd;
  final String paymentNetwork;
  final String paymentAsset;
  final String paymentWalletAddress;
  final String transactionHash;
  final String proofUrl;
  final String status;
}

class AdminSupportTicket {
  const AdminSupportTicket({
    required this.id,
    required this.uid,
    required this.subject,
    required this.status,
    required this.messageCount,
    required this.latestMessage,
    required this.userEmail,
    required this.userDisplayName,
    required this.updatedAt,
  });

  factory AdminSupportTicket.fromJson(Map<String, dynamic> json) {
    return AdminSupportTicket(
      id: json['id'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      latestMessage: json['latestMessage'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      userDisplayName: json['userDisplayName'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  final String id;
  final String uid;
  final String subject;
  final String status;
  final int messageCount;
  final String latestMessage;
  final String userEmail;
  final String userDisplayName;
  final String updatedAt;

  String get requesterLabel {
    final name = userDisplayName.trim();
    if (name.isNotEmpty) return name;
    final email = userEmail.trim();
    return email.isNotEmpty ? email : uid;
  }

  String get statusLabel {
    return switch (status) {
      'waiting_for_admin' => 'Waiting for admin',
      'waiting_for_member' => 'Waiting for member',
      'closed' => 'Closed',
      _ => 'Open',
    };
  }
}

class WithdrawalPolicy {
  const WithdrawalPolicy({
    required this.minimumAmountUsd,
    required this.flatFeeUsd,
    required this.percentageFee,
    required this.requiresDestinationWalletVerification,
    required this.requiredApprovals,
    required this.processingTime,
    required this.enabled,
    required this.notes,
  });

  factory WithdrawalPolicy.defaults() {
    return const WithdrawalPolicy(
      minimumAmountUsd: 25,
      flatFeeUsd: 0,
      percentageFee: 0,
      requiresDestinationWalletVerification: true,
      requiredApprovals: 1,
      processingTime: '1-2 business days',
      enabled: true,
      notes: 'Admin verification is required before release.',
    );
  }

  factory WithdrawalPolicy.fromJson(Map<String, dynamic> json) {
    final defaults = WithdrawalPolicy.defaults();
    return WithdrawalPolicy(
      minimumAmountUsd:
          (json['minimumAmountUsd'] as num?)?.toDouble() ??
          defaults.minimumAmountUsd,
      flatFeeUsd:
          (json['flatFeeUsd'] as num?)?.toDouble() ?? defaults.flatFeeUsd,
      percentageFee:
          (json['percentageFee'] as num?)?.toDouble() ?? defaults.percentageFee,
      requiresDestinationWalletVerification:
          json['requiresDestinationWalletVerification'] as bool? ??
          defaults.requiresDestinationWalletVerification,
      requiredApprovals:
          (json['requiredApprovals'] as num?)?.toInt() ??
          defaults.requiredApprovals,
      processingTime:
          json['processingTime'] as String? ?? defaults.processingTime,
      enabled: json['enabled'] as bool? ?? defaults.enabled,
      notes: json['notes'] as String? ?? defaults.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minimumAmountUsd': minimumAmountUsd,
      'flatFeeUsd': flatFeeUsd,
      'percentageFee': percentageFee,
      'requiresDestinationWalletVerification':
          requiresDestinationWalletVerification,
      'requiredApprovals': requiredApprovals,
      'processingTime': processingTime,
      'enabled': enabled,
      'notes': notes,
    };
  }

  final double minimumAmountUsd;
  final double flatFeeUsd;
  final double percentageFee;
  final bool requiresDestinationWalletVerification;
  final int requiredApprovals;
  final String processingTime;
  final bool enabled;
  final String notes;

  double feeFor(double amountUsd) {
    return flatFeeUsd + (amountUsd * percentageFee / 100);
  }
}

class ReferralPolicy {
  const ReferralPolicy({
    required this.enabled,
    required this.commissionPercent,
    required this.firstInvestmentOnly,
  });

  factory ReferralPolicy.defaults() {
    return const ReferralPolicy(
      enabled: true,
      commissionPercent: 5,
      firstInvestmentOnly: false,
    );
  }

  factory ReferralPolicy.fromJson(Map<String, dynamic> json) {
    final defaults = ReferralPolicy.defaults();
    return ReferralPolicy(
      enabled: json['enabled'] as bool? ?? defaults.enabled,
      commissionPercent:
          (json['commissionPercent'] as num?)?.toDouble() ??
          defaults.commissionPercent,
      firstInvestmentOnly:
          json['firstInvestmentOnly'] as bool? ?? defaults.firstInvestmentOnly,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'commissionPercent': commissionPercent,
      'firstInvestmentOnly': firstInvestmentOnly,
    };
  }

  ReferralPolicy copyWith({
    bool? enabled,
    double? commissionPercent,
    bool? firstInvestmentOnly,
  }) {
    return ReferralPolicy(
      enabled: enabled ?? this.enabled,
      commissionPercent: commissionPercent ?? this.commissionPercent,
      firstInvestmentOnly: firstInvestmentOnly ?? this.firstInvestmentOnly,
    );
  }

  final bool enabled;
  final double commissionPercent;
  final bool firstInvestmentOnly;
}

class AdminKycProfile {
  const AdminKycProfile({
    required this.uid,
    required this.email,
    required this.fullLegalName,
    required this.phoneNumber,
    required this.status,
    required this.rejectionReason,
    required this.submittedAt,
  });

  factory AdminKycProfile.fromJson(Map<String, dynamic> json) {
    return AdminKycProfile(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullLegalName: json['fullLegalName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'notStarted',
      rejectionReason: json['rejectionReason'] as String? ?? '',
      submittedAt: json['submittedAt'] as String? ?? '',
    );
  }

  final String uid;
  final String email;
  final String fullLegalName;
  final String phoneNumber;
  final String status;
  final String rejectionReason;
  final String submittedAt;

  String get statusLabel => switch (status) {
    'notStarted' => 'Not started',
    'inProgress' => 'In progress',
    'submitted' => 'Submitted',
    'approved' => 'Approved',
    'rejected' => 'Rejected',
    _ => status,
  };

  bool get needsReview => status == 'submitted';
  bool get isApproved => status == 'approved';
}

List<T> _list<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) {
    return const [];
  }

  return value
      .whereType<Map>()
      .map((item) => fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map((item) => item?.toString() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}
