// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'Language';

  @override
  String get languageScreenTitle => 'Language';

  @override
  String get languageHeading => 'Display language';

  @override
  String get languageDescription =>
      'Choose the language BrickClub uses on this device.';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonEmailHint => 'you@example.com';

  @override
  String get commonPassword => 'Password';

  @override
  String get authConnecting => 'Connecting...';

  @override
  String get signInWelcomeTitle => 'Welcome back';

  @override
  String get signInAdminTitle => 'Admin sign in';

  @override
  String get signInMemberSubtitle => 'Continue to your BrickShares portfolio.';

  @override
  String get signInAdminSubtitle =>
      'Access user, asset, and crypto payment operations.';

  @override
  String get signInPasswordHint => 'Enter your password';

  @override
  String get signInForgotPassword => 'Forgot password?';

  @override
  String get signInProgress => 'Signing in...';

  @override
  String get signInOpenAdminDashboard => 'Open admin dashboard';

  @override
  String get signInSubmit => 'Sign in securely';

  @override
  String get signInGoogleAdmin => 'Continue as admin with Google';

  @override
  String get signInGoogle => 'Continue with Google';

  @override
  String get signInPhone => 'Continue with phone';

  @override
  String get signInUseMember => 'Use member sign in';

  @override
  String get signInUseAdmin => 'Sign in as an admin';

  @override
  String get signInCreateAccount => 'Create a BrickClub account';

  @override
  String get signInGoogleNoAdmin =>
      'This Google account does not have admin access.';

  @override
  String get signInNoAdmin => 'This account does not have admin access.';

  @override
  String get signInResetSent => 'Password reset instructions sent';

  @override
  String get signInStoryTitle => 'Ownership, made\nmore accessible.';

  @override
  String get signInStoryBody =>
      'Review verified opportunities, settle with confidence, and keep every asset in view.';

  @override
  String get signUpIntro =>
      'Create your BrickShares account. Wallet verification and KYC come next.';

  @override
  String get signUpCreateAccount => 'Create account';

  @override
  String get signUpLegalNamesHint =>
      'Use your legal names exactly as they appear on your ID.';

  @override
  String get signUpFirstName => 'First name';

  @override
  String get signUpFirstNameHint => 'Legal first name';

  @override
  String get signUpLastName => 'Last name';

  @override
  String get signUpLastNameHint => 'Legal last name';

  @override
  String get signUpPasswordHint => 'Create a password';

  @override
  String get signUpConfirmPassword => 'Confirm password';

  @override
  String get signUpConfirmPasswordHint => 'Confirm your password';

  @override
  String get signUpAgree =>
      'I agree to terms, risk disclosures, and settlement confirmation notices.';

  @override
  String get signUpProgress => 'Creating account...';

  @override
  String get signUpGoogle => 'Sign up with Google';

  @override
  String get signUpDisclosure =>
      'Financial actions require KYC and verified wallet setup after account creation.';

  @override
  String get signUpHaveAccount => 'Already have an account? Sign in';

  @override
  String get phoneTitle => 'Sign in with phone';

  @override
  String get phoneOtpTitle => 'Enter verification code';

  @override
  String get phoneSubtitle =>
      'Enter your phone number with country code (e.g. +1 415 555 2671).';

  @override
  String phoneOtpSubtitle(String phone) {
    return 'We sent a 6-digit code to $phone.';
  }

  @override
  String get phoneHint => '+1 415 555 2671';

  @override
  String get phoneCodeHint => '000000';

  @override
  String get phoneSendingCode => 'Sending code…';

  @override
  String get phoneSendCode => 'Send verification code';

  @override
  String get phoneVerifying => 'Verifying…';

  @override
  String get phoneConfirmCode => 'Confirm code';

  @override
  String get phoneUseDifferentNumber => 'Use a different number';

  @override
  String get installIosTitle => 'Install on iPhone or iPad';

  @override
  String get installIosIntro =>
      'Add BrickClub to your home screen straight from Safari — no App Store needed.';

  @override
  String get installIosStep1 => 'Tap the Share button in Safari\'s toolbar.';

  @override
  String get installIosStep2 => 'Scroll down and choose “Add to Home Screen”.';

  @override
  String get installIosStep3 =>
      'Tap “Add” — BrickClub lands on your home screen.';

  @override
  String get installAndroidTitle => 'Install on Android';

  @override
  String get installAndroidIntro =>
      'Add BrickClub to your device in a couple of taps from your browser.';

  @override
  String get installAndroidStep1 =>
      'Open your browser menu (⋮ in the top corner).';

  @override
  String get installAndroidStep2 =>
      'Tap “Install app” or “Add to Home screen”.';

  @override
  String get installAndroidStep3 =>
      'Confirm — BrickClub appears in your app drawer.';

  @override
  String get installDesktopTitle => 'Install on desktop';

  @override
  String get installDesktopIntro =>
      'Install BrickClub as an app from Chrome or Edge.';

  @override
  String get installDesktopStep1 =>
      'Click the install icon in the address bar, or open the browser menu.';

  @override
  String get installDesktopStep2 =>
      'Choose “Install” to launch BrickClub in its own window.';

  @override
  String get installGotIt => 'Got it';

  @override
  String get installAlready => 'BrickClub is already installed on this device.';

  @override
  String get installInstalling => 'Installing BrickClub on your device…';

  @override
  String get installDismissed => 'Install dismissed. You can install any time.';

  @override
  String get navFeatures => 'Features';

  @override
  String get navHowItWorks => 'How it works';

  @override
  String get navTestimonials => 'Testimonials';

  @override
  String get landingSignIn => 'Sign in';

  @override
  String get landingSignUp => 'Sign up';

  @override
  String get landingJoin => 'Join';

  @override
  String get landingCreateAccount => 'Create account';

  @override
  String get heroTitle => 'Own more than\na dream.';

  @override
  String get heroBody =>
      'Build real ownership through verified property-backed BrickShares, with transparent performance and trusted crypto settlement from one secure app.';

  @override
  String get heroInstall => 'Install the app';

  @override
  String get heroExplore => 'Explore BrickShares';

  @override
  String get proofVerifiedAssets => 'Verified assets';

  @override
  String get proofTrustedSettlement => 'Trusted settlement';

  @override
  String get proofClearPerformance => 'Clear performance';

  @override
  String get previewPortfolioValue => 'Portfolio value';

  @override
  String get previewMinimum => 'Minimum';

  @override
  String get previewTargetReturn => 'Target return';

  @override
  String get heroCardTargetReturn => 'Target annual return';

  @override
  String get assetVerifiedBadge => 'VERIFIED ASSET';

  @override
  String get assetSampleDescription => 'Income-producing residential property';

  @override
  String get assetFunded => 'Funded';

  @override
  String get trustDueDiligence => 'PROPERTY DUE DILIGENCE';

  @override
  String get trustKycVerified => 'KYC VERIFIED MEMBERS';

  @override
  String get trustUsdtSettlement => 'USDT SETTLEMENT';

  @override
  String get trustOwnershipRecords => 'CLEAR OWNERSHIP RECORDS';

  @override
  String get statTargetReturn => 'Average target return';

  @override
  String get statMinimum => 'Minimum to start';

  @override
  String get statSettlement => 'On-chain settlement';

  @override
  String get statVisibility => 'Portfolio visibility';

  @override
  String get howTitle => 'From signup to ownership.';

  @override
  String get howSubtitle =>
      'A clear path designed for investors who want confidence at every step.';

  @override
  String get howStep1Title => 'Create and verify';

  @override
  String get howStep1Body =>
      'Open your account, complete KYC, and connect a verified wallet.';

  @override
  String get howStep2Title => 'Choose BrickShares';

  @override
  String get howStep2Body =>
      'Review verified assets, target returns, risks, and ownership terms.';

  @override
  String get howStep3Title => 'Fund and track';

  @override
  String get howStep3Body =>
      'Settle securely with supported crypto and monitor your portfolio.';

  @override
  String get featuresTitle => 'Built for clarity,\nnot speculation.';

  @override
  String get featuresBody =>
      'Every opportunity brings the important information forward: ownership structure, asset verification, target returns, risks, funding network, and settlement status.';

  @override
  String get feature1 => 'Verified asset documentation';

  @override
  String get feature2 => 'Transparent crypto quotes and network fees';

  @override
  String get feature3 => 'Confirmation before every financial action';

  @override
  String get testimonialsTitle => 'Built on investor confidence.';

  @override
  String get testimonialsSubtitle =>
      'What early BrickClub members value most about the experience.';

  @override
  String get testimonial1Quote =>
      'BrickClub makes the important details easy to understand. I know what I own, how it is performing, and what happens before I fund.';

  @override
  String get testimonial1Role => 'Entrepreneur, London';

  @override
  String get testimonial2Quote =>
      'The verification and confirmation flow gave me confidence. It feels like a serious investment platform, not another crypto shortcut.';

  @override
  String get testimonial2Role => 'Product lead, Singapore';

  @override
  String get testimonial3Quote =>
      'I can start at a practical amount and still get access to assets I would normally only watch from the outside.';

  @override
  String get testimonial3Role => 'Consultant, Dubai';

  @override
  String get ctaBadge => 'GET STARTED IN MINUTES';

  @override
  String get ctaTitle => 'Your next asset can start here.';

  @override
  String get ctaBody =>
      'Install BrickClub, create your account, and explore verified BrickShares built for long-term ownership.';

  @override
  String get ctaHaveAccount => 'I already have an account';

  @override
  String get ctaSecureKyc => 'Secure KYC';

  @override
  String get ctaFreeToBrowse => 'Free to browse';

  @override
  String get ctaVerifiedOnly => 'Verified assets only';

  @override
  String get footerCopyright => '© 2026 BrickClub';
}
