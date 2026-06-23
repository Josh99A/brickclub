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
  final referralController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill the referral code from a shared invite link (e.g. ?ref=ABC123).
    // On non-web platforms Uri.base has no query, so this is a no-op there.
    final referral = Uri.base.queryParameters['ref']?.trim() ?? '';
    if (referral.isNotEmpty) {
      referralController.text = referral.toUpperCase();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
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
                    icon: Icon(
                      isRtl ? Icons.chevron_right : Icons.chevron_left,
                      size: 34,
                    ),
                    padding: EdgeInsets.zero,
                    alignment: AlignmentDirectional.centerStart,
                  ),

                  const _BrandLockup(height: 112),
                  SizedBox(height: 10),
                  Text(
                    l10n.signUpIntro,
                    style: AppText.bodyLarge,
                  ),
                  SizedBox(height: 26),
                  Panel(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.signUpCreateAccount, style: AppText.h2),
                        Text(
                          l10n.signUpLegalNamesHint,
                          style: AppText.body,
                        ),
                        SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stackNames = constraints.maxWidth < 350;
                            final firstName = _SignUpField(
                              label: l10n.signUpFirstName,
                              child: AppTextField(
                                controller: firstNameController,
                                hintText: l10n.signUpFirstNameHint,
                                compact: true,
                                prefixIcon: Icons.badge_outlined,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.givenName],
                              ),
                            );
                            final lastName = _SignUpField(
                              label: l10n.signUpLastName,
                              child: AppTextField(
                                controller: lastNameController,
                                hintText: l10n.signUpLastNameHint,
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
                          label: l10n.commonEmail,
                          child: AppTextField(
                            controller: emailController,
                            hintText: l10n.commonEmailHint,
                            keyboardType: TextInputType.emailAddress,
                            compact: true,
                            prefixIcon: Icons.alternate_email_rounded,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                          ),
                        ),
                        SizedBox(height: 14),
                        _SignUpField(
                          label: l10n.commonPassword,
                          child: AppTextField(
                            controller: passwordController,
                            hintText: l10n.signUpPasswordHint,
                            obscureText: true,
                            compact: true,
                            prefixIcon: Icons.lock_outline_rounded,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                        ),
                        SizedBox(height: 14),
                        _SignUpField(
                          label: l10n.signUpConfirmPassword,
                          child: AppTextField(
                            controller: confirmPasswordController,
                            hintText: l10n.signUpConfirmPasswordHint,
                            obscureText: true,
                            compact: true,
                            prefixIcon: Icons.lock_reset_rounded,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                        ),
                        SizedBox(height: 14),
                        _SignUpField(
                          label: l10n.signUpReferralCode,
                          child: AppTextField(
                            controller: referralController,
                            hintText: l10n.signUpReferralCodeHint,
                            compact: true,
                            prefixIcon: Icons.card_giftcard_rounded,
                            textInputAction: TextInputAction.done,
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
                                  l10n.signUpAgree,
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
                        ? l10n.signUpProgress
                        : l10n.signUpCreateAccount,
                    onPressed: accepted && !creatingAccount
                        ? _createAccount
                        : null,
                  ),
                  SizedBox(height: 10),
                  GoogleAuthButton(
                    key: const ValueKey('google-sign-up'),
                    label: signingUpWithGoogle
                        ? l10n.authConnecting
                        : l10n.signUpGoogle,
                    onPressed: creatingAccount || signingUpWithGoogle
                        ? null
                        : _signUpWithGoogle,
                  ),
                  SizedBox(height: 10),
                  Text(
                    l10n.signUpDisclosure,
                    textAlign: TextAlign.center,
                    style: AppText.disclosure,
                  ),
                  SizedBox(height: 10),
                  SecondaryButton(
                    key: const ValueKey('account-login-button'),
                    label: l10n.signUpHaveAccount,
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
    final l10n = AppLocalizations.of(context);
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
        _showAuthMessage(_authErrorMessage(l10n, error));
      }
    } finally {
      if (mounted) {
        setState(() => signingUpWithGoogle = false);
      }
    }
  }

  Future<void> _createAccount() async {
    final l10n = AppLocalizations.of(context);
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
          referralCode: referralController.text,
        ),
      );

      if (mounted) {
        widget.onCreated();
      }
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(l10n, error));
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

