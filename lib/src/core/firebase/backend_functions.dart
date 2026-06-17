import 'package:cloud_functions/cloud_functions.dart';

class BackendFunctions {
  BackendFunctions({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<MemberProfileDto> getMemberProfile() async {
    final callable = _functions.httpsCallable('getMemberProfile');
    final result = await callable.call<Map<String, dynamic>>();

    return MemberProfileDto.fromJson(result.data);
  }

  Future<void> sendDevelopmentEmailVerification() async {
    final callable = _functions.httpsCallable(
      'sendDevelopmentEmailVerification',
    );
    await callable.call<void>();
  }

  Future<void> sendDevelopmentPasswordResetEmail(String email) async {
    final callable = _functions.httpsCallable(
      'sendDevelopmentPasswordResetEmail',
    );
    await callable.call<void>({'email': email.trim()});
  }

  Future<void> registerMessagingToken({
    required String token,
    required String platform,
  }) async {
    final callable = _functions.httpsCallable('registerMessagingToken');
    await callable.call<void>({'token': token, 'platform': platform});
  }

  Future<void> submitKycProfile(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('submitKycProfile');
    await callable.call<void>(data);
  }
}

class MemberProfileDto {
  const MemberProfileDto({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.emailVerified,
  });

  factory MemberProfileDto.fromJson(Map<String, dynamic> json) {
    return MemberProfileDto(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
  }

  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;
}
