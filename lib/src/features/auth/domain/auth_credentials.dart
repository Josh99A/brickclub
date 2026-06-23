class SignInCredentials {
  const SignInCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

class SignUpCredentials {
  const SignUpCredentials({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.referralCode = '',
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;

  /// Optional referral code captured at signup (from a friend's invite link or
  /// typed manually). Empty when the member signed up without one.
  final String referralCode;
}
