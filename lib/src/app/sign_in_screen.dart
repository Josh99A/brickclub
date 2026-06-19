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
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: widget.onBack,
                              icon: Icon(Icons.arrow_back_rounded),
                            ),
                          ),
                          SizedBox(height: 18),
                          const _BrandLockup(height: 72),
                          SizedBox(height: 30),
                          Text(
                            adminAccess ? 'Admin sign in' : 'Welcome back',
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
                                ? 'Access user, asset, and crypto payment operations.'
                                : 'Continue to your BrickShares portfolio.',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24),
                          const FieldLabel('Email'),
                          SizedBox(height: 8),
                          AppTextField(
                            key: const ValueKey('email-field'),
                            controller: emailController,
                            hintText: 'you@example.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 18),
                          const FieldLabel('Password'),
                          SizedBox(height: 8),
                          AppTextField(
                            key: const ValueKey('password-field'),
                            controller: passwordController,
                            hintText: 'Enter your password',
                            obscureText: true,
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _sendPasswordReset,
                              child: Text('Forgot password?'),
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
                                ? 'Signing in...'
                                : adminAccess
                                ? 'Open admin dashboard'
                                : 'Sign in securely',
                            onPressed: signingIn ? null : _signIn,
                          ),
                          SizedBox(height: 12),
                          GoogleAuthButton(
                            key: const ValueKey('google-sign-in'),
                            label: signingInWithGoogle
                                ? 'Connecting...'
                                : adminAccess
                                ? 'Continue as admin with Google'
                                : 'Continue with Google',
                            onPressed: signingIn || signingInWithGoogle
                                ? null
                                : _signInWithGoogle,
                          ),
                          if (!adminAccess) ...[
                            SizedBox(height: 10),
                            SecondaryButton(
                              key: const ValueKey('phone-sign-in'),
                              label: 'Continue with phone',
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
                                    ? 'Use member sign in'
                                    : 'Sign in as an admin',
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              key: const ValueKey('create-account-link'),
                              onPressed: widget.onCreateAccount,
                              child: Text('Create a BrickClub account'),
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
          _showAuthMessage('This Google account does not have admin access.');
          return;
        }

        widget.onAdminSignedIn();
        return;
      }

      widget.onMemberSignedIn();
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => signingInWithGoogle = false);
      }
    }
  }

  Future<void> _signIn() async {
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
          _showAuthMessage('This account does not have admin access.');
          return;
        }

        widget.onAdminSignedIn();
        return;
      }

      widget.onMemberSignedIn();
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(error));
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
    setState(() => authMessage = null);
    try {
      await widget.authRepository.sendPasswordResetEmail(emailController.text);
      if (mounted) {
        showMessage(context, 'Password reset instructions sent');
      }
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(error));
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
              'Ownership, made\nmore accessible.',
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
                'Review verified opportunities, settle with confidence, '
                'and keep every asset in view.',
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

