part of 'brickclub_app.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    required this.authRepository,
    required this.onBack,
    required this.onMemberSignedIn,
    required this.onAdminSignedIn,
    required this.onCreateAccount,
  });

  final AuthRepository authRepository;
  final VoidCallback onBack;
  final VoidCallback onMemberSignedIn;
  final VoidCallback onAdminSignedIn;
  final VoidCallback onCreateAccount;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool adminAccess = false;
  bool signingIn = false;
  bool signingInWithGoogle = false;
  String? authMessage;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (MediaQuery.sizeOf(context).width >= 900)
            const Expanded(child: _SignInStory()),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: IconButton(
                              onPressed: widget.onBack,
                              icon: Icon(
                                isRtl
                                    ? Icons.arrow_forward_rounded
                                    : Icons.arrow_back_rounded,
                              ),
                            ),
                          ),
                          SizedBox(height: 18),
                          const _BrandLockup(height: 72),
                          SizedBox(height: 30),
                          Text(
                            adminAccess
                                ? l10n.signInAdminTitle
                                : l10n.signInWelcomeTitle,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            adminAccess
                                ? l10n.signInAdminSubtitle
                                : l10n.signInMemberSubtitle,
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24),
                          FieldLabel(l10n.commonEmail),
                          SizedBox(height: 8),
                          AppTextField(
                            key: const ValueKey('email-field'),
                            controller: emailController,
                            hintText: l10n.commonEmailHint,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 18),
                          FieldLabel(l10n.commonPassword),
                          SizedBox(height: 8),
                          AppTextField(
                            key: const ValueKey('password-field'),
                            controller: passwordController,
                            hintText: l10n.signInPasswordHint,
                            obscureText: true,
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: _sendPasswordReset,
                              child: Text(l10n.signInForgotPassword),
                            ),
                          ),
                          SizedBox(height: 10),
                          if (authMessage != null) ...[
                            _AuthMessageBanner(message: authMessage!),
                            SizedBox(height: 14),
                          ],
                          PrimaryButton(
                            key: const ValueKey('sign-in'),
                            label: signingIn
                                ? l10n.signInProgress
                                : adminAccess
                                ? l10n.signInOpenAdminDashboard
                                : l10n.signInSubmit,
                            onPressed: signingIn ? null : _signIn,
                          ),
                          SizedBox(height: 12),
                          GoogleAuthButton(
                            key: const ValueKey('google-sign-in'),
                            label: signingInWithGoogle
                                ? l10n.authConnecting
                                : adminAccess
                                ? l10n.signInGoogleAdmin
                                : l10n.signInGoogle,
                            onPressed: signingIn || signingInWithGoogle
                                ? null
                                : _signInWithGoogle,
                          ),
                          if (!adminAccess) ...[
                            SizedBox(height: 10),
                            SecondaryButton(
                              key: const ValueKey('phone-sign-in'),
                              label: l10n.signInPhone,
                              onPressed: signingIn || signingInWithGoogle
                                  ? null
                                  : _signInWithPhone,
                            ),
                          ],
                          SizedBox(height: 24),
                          Center(
                            child: TextButton.icon(
                              key: const ValueKey('admin-access'),
                              onPressed: () {
                                setState(() {
                                  adminAccess = !adminAccess;
                                  authMessage = null;
                                  emailController.clear();
                                  passwordController.clear();
                                });
                              },
                              icon: Icon(
                                adminAccess
                                    ? Icons.person_outline_rounded
                                    : Icons.admin_panel_settings_outlined,
                              ),
                              label: Text(
                                adminAccess
                                    ? l10n.signInUseMember
                                    : l10n.signInUseAdmin,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              key: const ValueKey('create-account-link'),
                              onPressed: widget.onCreateAccount,
                              child: Text(l10n.signInCreateAccount),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      authMessage = null;
      signingInWithGoogle = true;
    });
    try {
      await widget.authRepository.signInWithGoogle();

      if (!mounted) {
        return;
      }

      if (adminAccess) {
        final isAdmin = await widget.authRepository.currentUserIsAdmin();
        if (!mounted) {
          return;
        }

        if (!isAdmin) {
          _showAuthMessage(l10n.signInGoogleNoAdmin);
          return;
        }

        widget.onAdminSignedIn();
        return;
      }

      widget.onMemberSignedIn();
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(l10n, error));
      }
    } finally {
      if (mounted) {
        setState(() => signingInWithGoogle = false);
      }
    }
  }

  Future<void> _signIn() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      authMessage = null;
      signingIn = true;
    });
    try {
      await widget.authRepository.signIn(
        SignInCredentials(
          email: emailController.text,
          password: passwordController.text,
        ),
      );

      if (!mounted) {
        return;
      }

      if (adminAccess) {
        final isAdmin = await widget.authRepository.currentUserIsAdmin();
        if (!mounted) {
          return;
        }

        if (!isAdmin) {
          _showAuthMessage(l10n.signInNoAdmin);
          return;
        }

        widget.onAdminSignedIn();
        return;
      }

      widget.onMemberSignedIn();
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(l10n, error));
      }
    } finally {
      if (mounted) {
        setState(() => signingIn = false);
      }
    }
  }

  Future<void> _signInWithPhone() async {
    await showPhoneSignInSheet(
      context,
      authRepository: widget.authRepository,
      onSignedIn: widget.onMemberSignedIn,
    );
  }

  Future<void> _sendPasswordReset() async {
    final l10n = AppLocalizations.of(context);
    setState(() => authMessage = null);
    try {
      await widget.authRepository.sendPasswordResetEmail(emailController.text);
      if (mounted) {
        showMessage(context, l10n.signInResetSent);
      }
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(l10n, error));
      }
    }
  }

  void _showAuthMessage(String message) {
    setState(() => authMessage = message);
    showMessage(context, message);
  }
}

class _AuthMessageBanner extends StatelessWidget {
  const _AuthMessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const ValueKey('auth-message'),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: .5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInStory extends StatelessWidget {
  const _SignInStory();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/skyline_heights.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x7A0B0D0F), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              l10n.signInStoryTitle,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 54,
                height: 1.02,
                fontWeight: FontWeight.w800,
                letterSpacing: -2,
              ),
            ),
            SizedBox(height: 22),
            SizedBox(
              width: 500,
              child: Text(
                l10n.signInStoryBody,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

