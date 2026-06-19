class AdminDashboardData {
  const AdminDashboardData({
    required this.users,
    required this.assets,
    required this.cryptoPaymentOptions,
    required this.depositRequests,
    required this.supportTickets,
    required this.withdrawalPolicy,
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
    return AdminAsset(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      type: json['type'] as String? ?? '',
      fundedPercent: (json['fundedPercent'] as num?)?.toDouble() ?? 0,
      reviewStatus: json['reviewStatus'] as String? ?? 'Pending',
      publishedStatus: json['publishedStatus'] as String? ?? 'Draft',
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
    };
  }

  final String id;
  final String title;
  final String location;
  final String type;
  final double fundedPercent;
  final String reviewStatus;
  final String publishedStatus;
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
