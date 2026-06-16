import 'kyc_models.dart';

abstract interface class KycRepository {
  Stream<KycProfile> watchProfile();

  Future<void> submit(KycSubmission submission);

  Future<void> sendEmailVerification();

  Future<void> sendPhoneVerificationCode(String phoneNumber);
}

class KycValidationException implements Exception {
  const KycValidationException(this.message);

  final String message;
}
