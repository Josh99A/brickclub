import 'dart:typed_data';

enum KycStatus { notStarted, inProgress, submitted, approved, rejected }

class KycProfile {
  const KycProfile({
    required this.status,
    required this.emailVerified,
    required this.phoneVerified,
    this.fullLegalName,
    this.dateOfBirth,
    this.phoneNumber,
    this.rejectionReason,
  });

  final KycStatus status;
  final bool emailVerified;
  final bool phoneVerified;
  final String? fullLegalName;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? rejectionReason;

  bool get canPerformFinancialActions => status == KycStatus.approved;

  double get completionRatio {
    var completed = 0;
    if ((fullLegalName ?? '').isNotEmpty) completed++;
    if (dateOfBirth != null) completed++;
    if ((phoneNumber ?? '').isNotEmpty) completed++;
    if (emailVerified) completed++;
    if (phoneVerified) completed++;
    if (status == KycStatus.submitted || status == KycStatus.approved) {
      completed += 3;
    }
    return completed / 8;
  }

  String get label {
    return switch (status) {
      KycStatus.notStarted => 'Not started',
      KycStatus.inProgress => 'In progress',
      KycStatus.submitted => 'Under review',
      KycStatus.approved => 'Approved',
      KycStatus.rejected => 'Needs attention',
    };
  }
}

class KycDocumentFile {
  const KycDocumentFile({
    required this.name,
    required this.bytes,
    required this.contentType,
  });

  final String name;
  final Uint8List bytes;
  final String contentType;
}

class KycSubmission {
  const KycSubmission({
    required this.fullLegalName,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.phoneVerificationCode,
    required this.governmentId,
    required this.selfie,
    required this.addressProof,
  });

  final String fullLegalName;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String phoneVerificationCode;
  final KycDocumentFile governmentId;
  final KycDocumentFile selfie;
  final KycDocumentFile addressProof;
}
