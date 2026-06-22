import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('hi'),
    Locale('it'),
    Locale('ru'),
    Locale('sw'),
    Locale('zh'),
  ];

  /// Application name, shown as the app title.
  ///
  /// In en, this message translates to:
  /// **'BrickClub'**
  String get appTitle;

  /// Label for the language row in the profile settings list.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// App bar title of the language selection screen.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageScreenTitle;

  /// Heading on the language selection screen.
  ///
  /// In en, this message translates to:
  /// **'Display language'**
  String get languageHeading;

  /// Subtitle explaining what the language setting does.
  ///
  /// In en, this message translates to:
  /// **'Choose the language BrickClub uses on this device.'**
  String get languageDescription;

  /// Option that follows the device's language automatically.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// Label for an email address input field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// Placeholder shown inside an email input field.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get commonEmailHint;

  /// Label for a password input field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// Button label while a Google sign-in/sign-up is in progress.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get authConnecting;

  /// Sign-in heading shown to members.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInWelcomeTitle;

  /// Sign-in heading shown when admin access is toggled on.
  ///
  /// In en, this message translates to:
  /// **'Admin sign in'**
  String get signInAdminTitle;

  /// Sign-in subtitle shown to members.
  ///
  /// In en, this message translates to:
  /// **'Continue to your BrickShares portfolio.'**
  String get signInMemberSubtitle;

  /// Sign-in subtitle shown when admin access is toggled on.
  ///
  /// In en, this message translates to:
  /// **'Access user, asset, and crypto payment operations.'**
  String get signInAdminSubtitle;

  /// Placeholder for the password field on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get signInPasswordHint;

  /// Link that triggers a password reset email.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get signInForgotPassword;

  /// Sign-in button label while signing in.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signInProgress;

  /// Sign-in submit button label in admin mode.
  ///
  /// In en, this message translates to:
  /// **'Open admin dashboard'**
  String get signInOpenAdminDashboard;

  /// Sign-in submit button label in member mode.
  ///
  /// In en, this message translates to:
  /// **'Sign in securely'**
  String get signInSubmit;

  /// Google sign-in button label in admin mode.
  ///
  /// In en, this message translates to:
  /// **'Continue as admin with Google'**
  String get signInGoogleAdmin;

  /// Google sign-in button label in member mode.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInGoogle;

  /// Button that opens the phone sign-in sheet.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone'**
  String get signInPhone;

  /// Toggle to switch from admin sign-in back to member sign-in.
  ///
  /// In en, this message translates to:
  /// **'Use member sign in'**
  String get signInUseMember;

  /// Toggle to switch to admin sign-in.
  ///
  /// In en, this message translates to:
  /// **'Sign in as an admin'**
  String get signInUseAdmin;

  /// Link from the sign-in screen to account creation.
  ///
  /// In en, this message translates to:
  /// **'Create a BrickClub account'**
  String get signInCreateAccount;

  /// Error when a Google account lacks admin access.
  ///
  /// In en, this message translates to:
  /// **'This Google account does not have admin access.'**
  String get signInGoogleNoAdmin;

  /// Error when an email account lacks admin access.
  ///
  /// In en, this message translates to:
  /// **'This account does not have admin access.'**
  String get signInNoAdmin;

  /// Confirmation after a password reset email is sent.
  ///
  /// In en, this message translates to:
  /// **'Password reset instructions sent'**
  String get signInResetSent;

  /// Marketing headline on the wide sign-in side panel.
  ///
  /// In en, this message translates to:
  /// **'Ownership, made\nmore accessible.'**
  String get signInStoryTitle;

  /// Marketing body text on the wide sign-in side panel.
  ///
  /// In en, this message translates to:
  /// **'Review verified opportunities, settle with confidence, and keep every asset in view.'**
  String get signInStoryBody;

  /// Intro text at the top of the sign-up screen.
  ///
  /// In en, this message translates to:
  /// **'Create your BrickShares account. Wallet verification and KYC come next.'**
  String get signUpIntro;

  /// Sign-up panel title and submit button label.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpCreateAccount;

  /// Guidance under the Create account panel title.
  ///
  /// In en, this message translates to:
  /// **'Use your legal names exactly as they appear on your ID.'**
  String get signUpLegalNamesHint;

  /// Label for the first name field.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get signUpFirstName;

  /// Placeholder for the first name field.
  ///
  /// In en, this message translates to:
  /// **'Legal first name'**
  String get signUpFirstNameHint;

  /// Label for the last name field.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get signUpLastName;

  /// Placeholder for the last name field.
  ///
  /// In en, this message translates to:
  /// **'Legal last name'**
  String get signUpLastNameHint;

  /// Placeholder for the password field on sign-up.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get signUpPasswordHint;

  /// Label for the confirm password field.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get signUpConfirmPassword;

  /// Placeholder for the confirm password field.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get signUpConfirmPasswordHint;

  /// Consent checkbox label on sign-up.
  ///
  /// In en, this message translates to:
  /// **'I agree to terms, risk disclosures, and settlement confirmation notices.'**
  String get signUpAgree;

  /// Submit button label while the account is being created.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get signUpProgress;

  /// Google sign-up button label.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpGoogle;

  /// Disclosure text near the bottom of the sign-up screen.
  ///
  /// In en, this message translates to:
  /// **'Financial actions require KYC and verified wallet setup after account creation.'**
  String get signUpDisclosure;

  /// Link from sign-up back to sign-in.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get signUpHaveAccount;

  /// Title of the phone sign-in sheet (number step).
  ///
  /// In en, this message translates to:
  /// **'Sign in with phone'**
  String get phoneTitle;

  /// Title of the phone sign-in sheet (code step).
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get phoneOtpTitle;

  /// Instruction on the phone number step.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number with country code (e.g. +1 415 555 2671).'**
  String get phoneSubtitle;

  /// Instruction on the code step, naming the destination number.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {phone}.'**
  String phoneOtpSubtitle(String phone);

  /// Placeholder for the phone number field.
  ///
  /// In en, this message translates to:
  /// **'+1 415 555 2671'**
  String get phoneHint;

  /// Placeholder for the verification code field.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get phoneCodeHint;

  /// Button label while the SMS code is being sent.
  ///
  /// In en, this message translates to:
  /// **'Sending code…'**
  String get phoneSendingCode;

  /// Button that requests an SMS verification code.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get phoneSendCode;

  /// Button label while the code is being verified.
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get phoneVerifying;

  /// Button that submits the verification code.
  ///
  /// In en, this message translates to:
  /// **'Confirm code'**
  String get phoneConfirmCode;

  /// Link to return to the phone number step.
  ///
  /// In en, this message translates to:
  /// **'Use a different number'**
  String get phoneUseDifferentNumber;

  /// No description provided for @installIosTitle.
  ///
  /// In en, this message translates to:
  /// **'Install on iPhone or iPad'**
  String get installIosTitle;

  /// No description provided for @installIosIntro.
  ///
  /// In en, this message translates to:
  /// **'Add BrickClub to your home screen straight from Safari — no App Store needed.'**
  String get installIosIntro;

  /// No description provided for @installIosStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap the Share button in Safari\'s toolbar.'**
  String get installIosStep1;

  /// No description provided for @installIosStep2.
  ///
  /// In en, this message translates to:
  /// **'Scroll down and choose “Add to Home Screen”.'**
  String get installIosStep2;

  /// No description provided for @installIosStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap “Add” — BrickClub lands on your home screen.'**
  String get installIosStep3;

  /// No description provided for @installAndroidTitle.
  ///
  /// In en, this message translates to:
  /// **'Install on Android'**
  String get installAndroidTitle;

  /// No description provided for @installAndroidIntro.
  ///
  /// In en, this message translates to:
  /// **'Add BrickClub to your device in a couple of taps from your browser.'**
  String get installAndroidIntro;

  /// No description provided for @installAndroidStep1.
  ///
  /// In en, this message translates to:
  /// **'Open your browser menu (⋮ in the top corner).'**
  String get installAndroidStep1;

  /// No description provided for @installAndroidStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap “Install app” or “Add to Home screen”.'**
  String get installAndroidStep2;

  /// No description provided for @installAndroidStep3.
  ///
  /// In en, this message translates to:
  /// **'Confirm — BrickClub appears in your app drawer.'**
  String get installAndroidStep3;

  /// No description provided for @installDesktopTitle.
  ///
  /// In en, this message translates to:
  /// **'Install on desktop'**
  String get installDesktopTitle;

  /// No description provided for @installDesktopIntro.
  ///
  /// In en, this message translates to:
  /// **'Install BrickClub as an app from Chrome or Edge.'**
  String get installDesktopIntro;

  /// No description provided for @installDesktopStep1.
  ///
  /// In en, this message translates to:
  /// **'Click the install icon in the address bar, or open the browser menu.'**
  String get installDesktopStep1;

  /// No description provided for @installDesktopStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose “Install” to launch BrickClub in its own window.'**
  String get installDesktopStep2;

  /// No description provided for @installGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get installGotIt;

  /// No description provided for @installAlready.
  ///
  /// In en, this message translates to:
  /// **'BrickClub is already installed on this device.'**
  String get installAlready;

  /// No description provided for @installInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing BrickClub on your device…'**
  String get installInstalling;

  /// No description provided for @installDismissed.
  ///
  /// In en, this message translates to:
  /// **'Install dismissed. You can install any time.'**
  String get installDismissed;

  /// No description provided for @navFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get navFeatures;

  /// No description provided for @navHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get navHowItWorks;

  /// No description provided for @navTestimonials.
  ///
  /// In en, this message translates to:
  /// **'Testimonials'**
  String get navTestimonials;

  /// No description provided for @landingSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get landingSignIn;

  /// No description provided for @landingSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get landingSignUp;

  /// No description provided for @landingJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get landingJoin;

  /// No description provided for @landingCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get landingCreateAccount;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Own more than\na dream.'**
  String get heroTitle;

  /// No description provided for @heroBody.
  ///
  /// In en, this message translates to:
  /// **'Build real ownership through verified property-backed BrickShares, with transparent performance and trusted crypto settlement from one secure app.'**
  String get heroBody;

  /// No description provided for @heroInstall.
  ///
  /// In en, this message translates to:
  /// **'Install the app'**
  String get heroInstall;

  /// No description provided for @heroExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore BrickShares'**
  String get heroExplore;

  /// No description provided for @proofVerifiedAssets.
  ///
  /// In en, this message translates to:
  /// **'Verified assets'**
  String get proofVerifiedAssets;

  /// No description provided for @proofTrustedSettlement.
  ///
  /// In en, this message translates to:
  /// **'Trusted settlement'**
  String get proofTrustedSettlement;

  /// No description provided for @proofClearPerformance.
  ///
  /// In en, this message translates to:
  /// **'Clear performance'**
  String get proofClearPerformance;

  /// No description provided for @previewPortfolioValue.
  ///
  /// In en, this message translates to:
  /// **'Portfolio value'**
  String get previewPortfolioValue;

  /// No description provided for @previewMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get previewMinimum;

  /// No description provided for @previewTargetReturn.
  ///
  /// In en, this message translates to:
  /// **'Target return'**
  String get previewTargetReturn;

  /// No description provided for @heroCardTargetReturn.
  ///
  /// In en, this message translates to:
  /// **'Target annual return'**
  String get heroCardTargetReturn;

  /// No description provided for @assetVerifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED ASSET'**
  String get assetVerifiedBadge;

  /// No description provided for @assetSampleDescription.
  ///
  /// In en, this message translates to:
  /// **'Income-producing residential property'**
  String get assetSampleDescription;

  /// No description provided for @assetFunded.
  ///
  /// In en, this message translates to:
  /// **'Funded'**
  String get assetFunded;

  /// No description provided for @trustDueDiligence.
  ///
  /// In en, this message translates to:
  /// **'PROPERTY DUE DILIGENCE'**
  String get trustDueDiligence;

  /// No description provided for @trustKycVerified.
  ///
  /// In en, this message translates to:
  /// **'KYC VERIFIED MEMBERS'**
  String get trustKycVerified;

  /// No description provided for @trustUsdtSettlement.
  ///
  /// In en, this message translates to:
  /// **'USDT SETTLEMENT'**
  String get trustUsdtSettlement;

  /// No description provided for @trustOwnershipRecords.
  ///
  /// In en, this message translates to:
  /// **'CLEAR OWNERSHIP RECORDS'**
  String get trustOwnershipRecords;

  /// No description provided for @statTargetReturn.
  ///
  /// In en, this message translates to:
  /// **'Average target return'**
  String get statTargetReturn;

  /// No description provided for @statMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum to start'**
  String get statMinimum;

  /// No description provided for @statSettlement.
  ///
  /// In en, this message translates to:
  /// **'On-chain settlement'**
  String get statSettlement;

  /// No description provided for @statVisibility.
  ///
  /// In en, this message translates to:
  /// **'Portfolio visibility'**
  String get statVisibility;

  /// No description provided for @howTitle.
  ///
  /// In en, this message translates to:
  /// **'From signup to ownership.'**
  String get howTitle;

  /// No description provided for @howSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A clear path designed for investors who want confidence at every step.'**
  String get howSubtitle;

  /// No description provided for @howStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Create and verify'**
  String get howStep1Title;

  /// No description provided for @howStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Open your account, complete KYC, and connect a verified wallet.'**
  String get howStep1Body;

  /// No description provided for @howStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Choose BrickShares'**
  String get howStep2Title;

  /// No description provided for @howStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Review verified assets, target returns, risks, and ownership terms.'**
  String get howStep2Body;

  /// No description provided for @howStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Fund and track'**
  String get howStep3Title;

  /// No description provided for @howStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Settle securely with supported crypto and monitor your portfolio.'**
  String get howStep3Body;

  /// No description provided for @featuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Built for clarity,\nnot speculation.'**
  String get featuresTitle;

  /// No description provided for @featuresBody.
  ///
  /// In en, this message translates to:
  /// **'Every opportunity brings the important information forward: ownership structure, asset verification, target returns, risks, funding network, and settlement status.'**
  String get featuresBody;

  /// No description provided for @feature1.
  ///
  /// In en, this message translates to:
  /// **'Verified asset documentation'**
  String get feature1;

  /// No description provided for @feature2.
  ///
  /// In en, this message translates to:
  /// **'Transparent crypto quotes and network fees'**
  String get feature2;

  /// No description provided for @feature3.
  ///
  /// In en, this message translates to:
  /// **'Confirmation before every financial action'**
  String get feature3;

  /// No description provided for @testimonialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Built on investor confidence.'**
  String get testimonialsTitle;

  /// No description provided for @testimonialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What early BrickClub members value most about the experience.'**
  String get testimonialsSubtitle;

  /// No description provided for @testimonial1Quote.
  ///
  /// In en, this message translates to:
  /// **'BrickClub makes the important details easy to understand. I know what I own, how it is performing, and what happens before I fund.'**
  String get testimonial1Quote;

  /// No description provided for @testimonial1Role.
  ///
  /// In en, this message translates to:
  /// **'Entrepreneur, London'**
  String get testimonial1Role;

  /// No description provided for @testimonial2Quote.
  ///
  /// In en, this message translates to:
  /// **'The verification and confirmation flow gave me confidence. It feels like a serious investment platform, not another crypto shortcut.'**
  String get testimonial2Quote;

  /// No description provided for @testimonial2Role.
  ///
  /// In en, this message translates to:
  /// **'Product lead, Singapore'**
  String get testimonial2Role;

  /// No description provided for @testimonial3Quote.
  ///
  /// In en, this message translates to:
  /// **'I can start at a practical amount and still get access to assets I would normally only watch from the outside.'**
  String get testimonial3Quote;

  /// No description provided for @testimonial3Role.
  ///
  /// In en, this message translates to:
  /// **'Consultant, Dubai'**
  String get testimonial3Role;

  /// No description provided for @ctaBadge.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED IN MINUTES'**
  String get ctaBadge;

  /// No description provided for @ctaTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next asset can start here.'**
  String get ctaTitle;

  /// No description provided for @ctaBody.
  ///
  /// In en, this message translates to:
  /// **'Install BrickClub, create your account, and explore verified BrickShares built for long-term ownership.'**
  String get ctaBody;

  /// No description provided for @ctaHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get ctaHaveAccount;

  /// No description provided for @ctaSecureKyc.
  ///
  /// In en, this message translates to:
  /// **'Secure KYC'**
  String get ctaSecureKyc;

  /// No description provided for @ctaFreeToBrowse.
  ///
  /// In en, this message translates to:
  /// **'Free to browse'**
  String get ctaFreeToBrowse;

  /// No description provided for @ctaVerifiedOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified assets only'**
  String get ctaVerifiedOnly;

  /// No description provided for @footerCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 BrickClub'**
  String get footerCopyright;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'hi',
    'it',
    'ru',
    'sw',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sw':
      return AppLocalizationsSw();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
