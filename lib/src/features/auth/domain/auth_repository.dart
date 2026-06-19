import 'auth_credentials.dart';

class SignedInUserDetails {
  const SignedInUserDetails({this.displayName, this.email});

  final String? displayName;
  final String? email;

  String get primaryLabel {
    final trimmedName = displayName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) return trimmedName;

    final trimmedEmail = email?.trim();
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) return trimmedEmail;

    return 'BrickClub member';
  }
}

abstract interface class AuthRepository {
  Future<void> signIn(SignInCredentials credentials);

  Future<void> signInWithGoogle();

  /// Sends an SMS verification code to [phoneNumber] (E.164 format, e.g. +14155552671).
  /// Returns the verificationId needed to confirm the code.
  Future<String> sendPhoneVerificationCode(String phoneNumber);

  /// Confirms the SMS [smsCode] received after [sendPhoneVerificationCode].
  Future<void> signInWithPhoneCode({
    required String verificationId,
    required String smsCode,
  });

  Future<void> createAccount(SignUpCredentials credentials);

  SignedInUserDetails? currentUserDetails();

  Future<void> sendPasswordResetEmail(String email);

  Future<bool> currentUserIsAdmin();

  Future<void> signOut();
}

class AuthValidationException implements Exception {
  const AuthValidationException(this.message);

  final String message;
}

class AuthOperationTimeoutException implements Exception {
  const AuthOperationTimeoutException(this.message);

  final String message;
}
