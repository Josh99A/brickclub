import 'referral_models.dart';

/// Member-facing referral data access. Implementations call privileged backend
/// callables; widgets never touch Firebase SDKs directly.
abstract interface class ReferralRepository {
  /// Loads (lazily creating on first access) the current member's referral
  /// profile: share code, referral count, lifetime earnings, the active
  /// commission rate, and recent commission history.
  Future<ReferralProfile> getReferralProfile();
}
