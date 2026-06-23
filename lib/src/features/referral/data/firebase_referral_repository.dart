import '../../../core/firebase/backend_functions.dart';
import '../domain/referral_models.dart';
import '../domain/referral_repository.dart';

class FirebaseReferralRepository implements ReferralRepository {
  FirebaseReferralRepository({BackendFunctions? backendFunctions})
    : _backendFunctions = backendFunctions ?? BackendFunctions();

  final BackendFunctions _backendFunctions;

  @override
  Future<ReferralProfile> getReferralProfile() async {
    final data = await _backendFunctions.getReferralProfile();
    return ReferralProfile.fromJson(data);
  }
}
