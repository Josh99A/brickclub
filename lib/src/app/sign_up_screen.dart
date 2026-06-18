part of 'brickclub_app.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.authRepository,
    required this.onBack,
    required this.onSignIn,
    required this.onCreated,
  });

  final AuthRepository authRepository;
  final VoidCallback onBack;
  final VoidCallback onSignIn;
  final VoidCallback onCreated;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool accepted = false;
  bool creatingAccount = false;
  bool signingUpWithGoogle = false;
  String? authMessage;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          color: AppColors.background,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: Icon(Icons.chevron_left, size: 34),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  const _BrandLockup(height: 112),
                  SizedBox(height: 10),
                  Text(
                    'Create your BrickShares account. Wallet verification '
                    'and KYC come next.',
                    style: AppText.bodyLarge,
                  ),
                  SizedBox(height: 26),
                  Panel(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create account', style: AppText.h2),
                        Text(
                          'Use your legal names exactly as they appear on your ID.',
                          style: AppText.body,
                        ),
                        SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stackNames = constraints.maxWidth < 350;
                            final firstName = _SignUpField(
                              label: 'First name',
                              child: AppTextField(
                                controller: firstNameController,
                                hintText: 'Legal first name',
                                compact: true,
                                prefixIcon: Icons.badge_outlined,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.givenName],
                              ),
                            );
                            final lastName = _SignUpField(
                              label: 'Last name',
                              child: AppTextField(
                                controller: lastNameController,
                                hintText: 'Legal last name',
                                compact: true,
                                prefixIcon: Icons.badge_outlined,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.familyName],
                              ),
                            );

                            if (stackNames) {
                              return Column(
                                children: [
                                  firstName,
                                  SizedBox(height: 14),
                                  lastName,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: firstName),
                                SizedBox(width: 12),
                                Expanded(child: lastName),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 14),
                        _SignUpField(
                          label: 'Email',
                          child: AppTextField(
                            controller: emailController,
                            hintText: 'you@example.com',
                            keyboardType: TextInputType.emailAddress,
                            compact: true,
                            prefixIcon: Icons.alternate_email_rounded,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                          ),
                        ),
                        SizedBox(height: 14),
                        _SignUpField(
                          label: 'Password',
                          child: AppTextField(
                            controller: passwordController,
                            hintText: 'Create a password',
                            obscureText: true,
                            compact: true,
                            prefixIcon: Icons.lock_outline_rounded,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                        ),
                        SizedBox(height: 14),
                        _SignUpField(
                          label: 'Confirm password',
                          child: AppTextField(
                            controller: confirmPasswordController,
                            hintText: 'Confirm your password',
                            obscureText: true,
                            compact: true,
                            prefixIcon: Icons.lock_reset_rounded,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: accepted,
                              onChanged: (value) => setState(() {
                                accepted = value ?? false;
                                authMessage = null;
                              }),
                              side: BorderSide(color: AppColors.border),
                              activeColor: AppColors.gold,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  'I agree to terms, risk disclosures, and '
                                  'settlement confirmation notices.',
                                  style: AppText.small,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  if (authMessage != null) ...[
                    _AuthMessageBanner(message: authMessage!),
                    SizedBox(height: 10),
                  ],
                  PrimaryButton(
                    key: const ValueKey('create-account-submit'),
                    label: creatingAccount
                        ? 'Creating account...'
                        : 'Create account',
                    onPressed: accepted && !creatingAccount
                        ? _createAccount
                        : null,
                  ),
                  SizedBox(height: 10),
                  GoogleAuthButton(
                    key: const ValueKey('google-sign-up'),
                    label: signingUpWithGoogle
                        ? 'Connecting...'
                        : 'Sign up with Google',
                    onPressed: creatingAccount || signingUpWithGoogle
                        ? null
                        : _signUpWithGoogle,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Financial actions require KYC and verified wallet setup '
                    'after account creation.',
                    textAlign: TextAlign.center,
                    style: AppText.disclosure,
                  ),
                  SizedBox(height: 10),
                  SecondaryButton(
                    key: const ValueKey('account-login-button'),
                    label: 'Already have an account? Sign in',
                    onPressed: widget.onSignIn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      authMessage = null;
      signingUpWithGoogle = true;
    });
    try {
      await widget.authRepository.signInWithGoogle();

      if (mounted) {
        widget.onCreated();
      }
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => signingUpWithGoogle = false);
      }
    }
  }

  Future<void> _createAccount() async {
    setState(() {
      authMessage = null;
      creatingAccount = true;
    });
    try {
      await widget.authRepository.createAccount(
        SignUpCredentials(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
        ),
      );

      if (mounted) {
        widget.onCreated();
      }
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => creatingAccount = false);
      }
    }
  }

  void _showAuthMessage(String message) {
    setState(() => authMessage = message);
    showMessage(context, message);
  }
}

class _SignUpField extends StatelessWidget {
  const _SignUpField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [FieldLabel(label), SizedBox(height: 7), child],
    );
  }
}

