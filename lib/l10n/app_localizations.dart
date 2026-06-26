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

  /// No description provided for @heroDownloadAndroid.
  ///
  /// In en, this message translates to:
  /// **'Download for Android'**
  String get heroDownloadAndroid;

  /// No description provided for @heroDownloadIos.
  ///
  /// In en, this message translates to:
  /// **'Download for iOS'**
  String get heroDownloadIos;

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
  /// **'© 1996–2026 BrickClub'**
  String get footerCopyright;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @navInvest.
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get navInvest;

  /// No description provided for @navWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// No description provided for @navPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get navPortfolio;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @kycGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete KYC first'**
  String get kycGateTitle;

  /// No description provided for @kycGateBody.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}. Purchases, withdrawals, wallet changes, and crypto settlement unlock after approval.'**
  String kycGateBody(String status);

  /// No description provided for @kycGateViewStatus.
  ///
  /// In en, this message translates to:
  /// **'View KYC status'**
  String get kycGateViewStatus;

  /// No description provided for @kycGateComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete KYC'**
  String get kycGateComplete;

  /// No description provided for @homeFeaturedOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Featured opportunity'**
  String get homeFeaturedOpportunity;

  /// No description provided for @homeNoLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'No live BrickShares yet'**
  String get homeNoLiveTitle;

  /// No description provided for @homeNoLiveBody.
  ///
  /// In en, this message translates to:
  /// **'Published, verified assets will appear here.'**
  String get homeNoLiveBody;

  /// No description provided for @homeViewInvest.
  ///
  /// In en, this message translates to:
  /// **'View invest'**
  String get homeViewInvest;

  /// No description provided for @homeYourHoldings.
  ///
  /// In en, this message translates to:
  /// **'Your holdings'**
  String get homeYourHoldings;

  /// No description provided for @homeRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get homeRecentActivity;

  /// No description provided for @holdingsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No holdings yet'**
  String get holdingsEmptyTitle;

  /// No description provided for @holdingsEmptyHome.
  ///
  /// In en, this message translates to:
  /// **'Verified deposits will appear here as BrickShares.'**
  String get holdingsEmptyHome;

  /// No description provided for @activityEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get activityEmptyTitle;

  /// No description provided for @activityEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Deposit requests and settlement updates will appear here.'**
  String get activityEmptyBody;

  /// No description provided for @dashboardErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load account data'**
  String get dashboardErrorTitle;

  /// No description provided for @dashboardErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check the backend connection and try again.'**
  String get dashboardErrorBody;

  /// No description provided for @investSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore verified multi-asset BrickShares'**
  String get investSubtitle;

  /// No description provided for @investSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, location, or asset class'**
  String get investSearchHint;

  /// No description provided for @investAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available {count}'**
  String investAvailable(int count);

  /// No description provided for @investFilteredIncome.
  ///
  /// In en, this message translates to:
  /// **'Filtered income\nBrickShares'**
  String get investFilteredIncome;

  /// No description provided for @investOpportunitiesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} opportunities'**
  String investOpportunitiesCount(int count);

  /// No description provided for @investLoadingOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Loading opportunities'**
  String get investLoadingOpportunities;

  /// No description provided for @investFiltersAction.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get investFiltersAction;

  /// No description provided for @investNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No BrickShares match'**
  String get investNoMatchTitle;

  /// No description provided for @investNoMatchEmpty.
  ///
  /// In en, this message translates to:
  /// **'Admin-published verified assets will appear here.'**
  String get investNoMatchEmpty;

  /// No description provided for @investNoMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No BrickShares match “{query}”. Try a different search or adjust your filters.'**
  String investNoMatchSearch(String query);

  /// No description provided for @investNoMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'Try a different asset class, risk level, or payment method.'**
  String get investNoMatchFilters;

  /// No description provided for @investResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get investResetFilters;

  /// No description provided for @walletCryptoActivity.
  ///
  /// In en, this message translates to:
  /// **'Crypto order activity'**
  String get walletCryptoActivity;

  /// No description provided for @walletFundingTitle.
  ///
  /// In en, this message translates to:
  /// **'Funding readiness'**
  String get walletFundingTitle;

  /// No description provided for @walletFundingBody.
  ///
  /// In en, this message translates to:
  /// **'Add a verified wallet before sending funds. Network, fees, quote expiry, and settlement status are shown before confirmation.'**
  String get walletFundingBody;

  /// No description provided for @walletAddWallet.
  ///
  /// In en, this message translates to:
  /// **'Add verified wallet'**
  String get walletAddWallet;

  /// No description provided for @walletVerificationStarted.
  ///
  /// In en, this message translates to:
  /// **'Wallet verification started'**
  String get walletVerificationStarted;

  /// No description provided for @walletSettlementTitle.
  ///
  /// In en, this message translates to:
  /// **'Settlement confirmation required'**
  String get walletSettlementTitle;

  /// No description provided for @walletSettlementBody.
  ///
  /// In en, this message translates to:
  /// **'Purchases, withdrawals, and wallet changes require final confirmation.'**
  String get walletSettlementBody;

  /// No description provided for @walletVerifiedBalance.
  ///
  /// In en, this message translates to:
  /// **'Verified wallet balance'**
  String get walletVerifiedBalance;

  /// No description provided for @portfolioCurrentValue.
  ///
  /// In en, this message translates to:
  /// **'Current portfolio value'**
  String get portfolioCurrentValue;

  /// No description provided for @portfolioInvested.
  ///
  /// In en, this message translates to:
  /// **'Invested'**
  String get portfolioInvested;

  /// No description provided for @portfolioProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit / loss'**
  String get portfolioProfitLoss;

  /// No description provided for @portfolioReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get portfolioReturn;

  /// No description provided for @portfolioDividends.
  ///
  /// In en, this message translates to:
  /// **'Dividends received: {amount}'**
  String portfolioDividends(String amount);

  /// No description provided for @portfolioHoldings.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get portfolioHoldings;

  /// No description provided for @portfolioHoldingsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Approved investments appear here automatically.'**
  String get portfolioHoldingsEmptyBody;

  /// No description provided for @portfolioAllocation.
  ///
  /// In en, this message translates to:
  /// **'Allocation'**
  String get portfolioAllocation;

  /// No description provided for @portfolioAllocationEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No allocation yet'**
  String get portfolioAllocationEmptyTitle;

  /// No description provided for @portfolioAllocationEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your asset mix appears after deposits verify.'**
  String get portfolioAllocationEmptyBody;

  /// No description provided for @portfolioInvestedOwnership.
  ///
  /// In en, this message translates to:
  /// **'Invested {invested} · {ownership} ownership'**
  String portfolioInvestedOwnership(String invested, String ownership);

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{mode} theme'**
  String profileThemeSubtitle(String mode);

  /// No description provided for @profileSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security & privacy'**
  String get profileSecurityTitle;

  /// No description provided for @profileSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified wallet and biometrics'**
  String get profileSecuritySubtitle;

  /// No description provided for @profileDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get profileDocumentsTitle;

  /// No description provided for @profileDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Statements, risk disclosures'**
  String get profileDocumentsSubtitle;

  /// No description provided for @profileRowOpened.
  ///
  /// In en, this message translates to:
  /// **'{title} opened'**
  String profileRowOpened(String title);

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupport;

  /// No description provided for @profileSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Message the BrickClub team'**
  String get profileSupportSubtitle;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get profileLogoutConfirmTitle;

  /// No description provided for @profileLogoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your account.'**
  String get profileLogoutConfirmBody;

  /// No description provided for @profileDefaultName.
  ///
  /// In en, this message translates to:
  /// **'BrickClub member'**
  String get profileDefaultName;

  /// No description provided for @profileDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your account and BrickShares details'**
  String get profileDefaultSubtitle;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @profileReferral.
  ///
  /// In en, this message translates to:
  /// **'Refer & earn'**
  String get profileReferral;

  /// No description provided for @profileReferralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and earn commission'**
  String get profileReferralSubtitle;

  /// No description provided for @referralScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Refer & earn'**
  String get referralScreenTitle;

  /// No description provided for @referralHeadline.
  ///
  /// In en, this message translates to:
  /// **'Invite friends, earn commission'**
  String get referralHeadline;

  /// No description provided for @referralHowItWorksBody.
  ///
  /// In en, this message translates to:
  /// **'Share your code. When someone you invited makes an investment, you earn {rate} of the amount they invest — credited straight to your wallet.'**
  String referralHowItWorksBody(String rate);

  /// No description provided for @referralYourCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your referral code'**
  String get referralYourCodeTitle;

  /// No description provided for @referralCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get referralCopyCode;

  /// No description provided for @referralCopied.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied'**
  String get referralCopied;

  /// No description provided for @referralLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied'**
  String get referralLinkCopied;

  /// No description provided for @referralShareInvite.
  ///
  /// In en, this message translates to:
  /// **'Share invite'**
  String get referralShareInvite;

  /// No description provided for @referralFriendsJoined.
  ///
  /// In en, this message translates to:
  /// **'Friends joined'**
  String get referralFriendsJoined;

  /// No description provided for @referralTotalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get referralTotalEarned;

  /// No description provided for @referralPaidToWalletNote.
  ///
  /// In en, this message translates to:
  /// **'You earn {rate} of every investment your referrals make, paid to your wallet.'**
  String referralPaidToWalletNote(String rate);

  /// No description provided for @referralDisabledNote.
  ///
  /// In en, this message translates to:
  /// **'Referral rewards are currently paused. Your code still works — earnings resume when rewards are switched back on.'**
  String get referralDisabledNote;

  /// No description provided for @referralRecentEarningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent earnings'**
  String get referralRecentEarningsTitle;

  /// No description provided for @referralNoEarningsYet.
  ///
  /// In en, this message translates to:
  /// **'No referral earnings yet. Share your code to get started.'**
  String get referralNoEarningsYet;

  /// No description provided for @referralCommissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{rate} of a {amount} investment'**
  String referralCommissionSubtitle(String rate, String amount);

  /// No description provided for @referralLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your referral details. Please try again.'**
  String get referralLoadError;

  /// No description provided for @signUpReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral code (optional)'**
  String get signUpReferralCode;

  /// No description provided for @signUpReferralCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a friend\'s code'**
  String get signUpReferralCodeHint;

  /// No description provided for @themeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeScreenTitle;

  /// No description provided for @themeAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeAppearance;

  /// No description provided for @themeAppearanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how BrickClub looks on this device.'**
  String get themeAppearanceDescription;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystemDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow this device automatically.'**
  String get themeSystemDescription;

  /// No description provided for @themeLightDescription.
  ///
  /// In en, this message translates to:
  /// **'Use a bright interface with dark text.'**
  String get themeLightDescription;

  /// No description provided for @themeDarkDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the classic dark BrickClub interface.'**
  String get themeDarkDescription;

  /// No description provided for @commonSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get commonSending;

  /// No description provided for @commonSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get commonSubmitting;

  /// No description provided for @filtersAssetClass.
  ///
  /// In en, this message translates to:
  /// **'Asset class'**
  String get filtersAssetClass;

  /// No description provided for @filtersRiskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk level'**
  String get filtersRiskLevel;

  /// No description provided for @filtersPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get filtersPaymentMethod;

  /// No description provided for @filtersReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filtersReset;

  /// No description provided for @filtersShow.
  ///
  /// In en, this message translates to:
  /// **'Show {count}'**
  String filtersShow(int count);

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Proof submitted'**
  String get successTitle;

  /// No description provided for @successBody.
  ///
  /// In en, this message translates to:
  /// **'Your proof of payment is awaiting admin verification. We will notify you after review.'**
  String get successBody;

  /// No description provided for @successSettlementStatus.
  ///
  /// In en, this message translates to:
  /// **'Settlement status'**
  String get successSettlementStatus;

  /// No description provided for @successViewPortfolio.
  ///
  /// In en, this message translates to:
  /// **'View portfolio'**
  String get successViewPortfolio;

  /// No description provided for @detailVerifiedDocs.
  ///
  /// In en, this message translates to:
  /// **'Verified docs'**
  String get detailVerifiedDocs;

  /// No description provided for @detailAssetLine.
  ///
  /// In en, this message translates to:
  /// **'{assetClass} BrickShares | {location}'**
  String detailAssetLine(String assetClass, String location);

  /// No description provided for @detailLiquidity.
  ///
  /// In en, this message translates to:
  /// **'Liquidity'**
  String get detailLiquidity;

  /// No description provided for @detailFundingStatus.
  ///
  /// In en, this message translates to:
  /// **'Funding status'**
  String get detailFundingStatus;

  /// No description provided for @detailFundedPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% funded'**
  String detailFundedPercent(String percent);

  /// No description provided for @detailFundingNote.
  ///
  /// In en, this message translates to:
  /// **'Supported payment options and quote expiry are shown before settlement confirmation.'**
  String get detailFundingNote;

  /// No description provided for @detailDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get detailDocuments;

  /// No description provided for @detailInvestButton.
  ///
  /// In en, this message translates to:
  /// **'Invest with crypto funding'**
  String get detailInvestButton;

  /// No description provided for @kycStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Financial actions are unlocked.'**
  String get kycStatusApproved;

  /// No description provided for @kycStatusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your documents are under review.'**
  String get kycStatusSubmitted;

  /// No description provided for @kycStatusRejectedDefault.
  ///
  /// In en, this message translates to:
  /// **'Review the request and resubmit.'**
  String get kycStatusRejectedDefault;

  /// No description provided for @kycStatusDefault.
  ///
  /// In en, this message translates to:
  /// **'Required before purchases and wallet changes.'**
  String get kycStatusDefault;

  /// No description provided for @kycChipPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get kycChipPhone;

  /// No description provided for @kycChipIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get kycChipIdentity;

  /// No description provided for @kycChipOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get kycChipOk;

  /// No description provided for @kycChipNeeded.
  ///
  /// In en, this message translates to:
  /// **'Needed'**
  String get kycChipNeeded;

  /// No description provided for @kycViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View KYC details'**
  String get kycViewDetails;

  /// No description provided for @kycVerifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get kycVerifyIdentity;

  /// No description provided for @kycFullName.
  ///
  /// In en, this message translates to:
  /// **'Full legal name'**
  String get kycFullName;

  /// No description provided for @kycFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name exactly as shown on your ID'**
  String get kycFullNameHint;

  /// No description provided for @kycDob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get kycDob;

  /// No description provided for @kycSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get kycSelectDate;

  /// No description provided for @kycGovId.
  ///
  /// In en, this message translates to:
  /// **'Government ID or passport'**
  String get kycGovId;

  /// No description provided for @kycUploadId.
  ///
  /// In en, this message translates to:
  /// **'Upload ID document'**
  String get kycUploadId;

  /// No description provided for @kycSelfie.
  ///
  /// In en, this message translates to:
  /// **'Selfie / face verification'**
  String get kycSelfie;

  /// No description provided for @kycCaptureSelfie.
  ///
  /// In en, this message translates to:
  /// **'Capture selfie'**
  String get kycCaptureSelfie;

  /// No description provided for @kycAddressProof.
  ///
  /// In en, this message translates to:
  /// **'Physical address proof'**
  String get kycAddressProof;

  /// No description provided for @kycUploadAddress.
  ///
  /// In en, this message translates to:
  /// **'Upload utility bill or lease'**
  String get kycUploadAddress;

  /// No description provided for @kycPhoneVerification.
  ///
  /// In en, this message translates to:
  /// **'Phone verification'**
  String get kycPhoneVerification;

  /// No description provided for @kycSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get kycSendCode;

  /// No description provided for @kycVerificationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get kycVerificationCodeHint;

  /// No description provided for @kycEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get kycEmailVerification;

  /// No description provided for @kycEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get kycEmailVerified;

  /// No description provided for @kycEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get kycEmailNotVerified;

  /// No description provided for @kycSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get kycSendEmail;

  /// No description provided for @kycSubmitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get kycSubmitForReview;

  /// No description provided for @kycEmulatorNote.
  ///
  /// In en, this message translates to:
  /// **'Phone codes appear in the Firebase Auth emulator. Development emails appear in Mailpit.'**
  String get kycEmulatorNote;

  /// No description provided for @kycEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get kycEmailSent;

  /// No description provided for @kycEnterPhoneFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number first'**
  String get kycEnterPhoneFirst;

  /// No description provided for @kycCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent. Check the Firebase Auth emulator.'**
  String get kycCodeSent;

  /// No description provided for @kycSubmitted.
  ///
  /// In en, this message translates to:
  /// **'KYC submitted for automatic checks'**
  String get kycSubmitted;

  /// No description provided for @kycMissingName.
  ///
  /// In en, this message translates to:
  /// **'Enter your legal name'**
  String get kycMissingName;

  /// No description provided for @kycMissingDob.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get kycMissingDob;

  /// No description provided for @kycMissingId.
  ///
  /// In en, this message translates to:
  /// **'Upload your ID or passport'**
  String get kycMissingId;

  /// No description provided for @kycMissingSelfie.
  ///
  /// In en, this message translates to:
  /// **'Capture a selfie'**
  String get kycMissingSelfie;

  /// No description provided for @kycMissingAddress.
  ///
  /// In en, this message translates to:
  /// **'Upload address proof'**
  String get kycMissingAddress;

  /// No description provided for @kycMissingPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get kycMissingPhone;

  /// No description provided for @kycInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number in international format, e.g. +12025550190.'**
  String get kycInvalidPhone;

  /// No description provided for @kycMissingCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone verification code'**
  String get kycMissingCode;

  /// No description provided for @kycUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not update your KYC details. Please try again.'**
  String get kycUpdateFailed;

  /// No description provided for @paymentConfirmFunding.
  ///
  /// In en, this message translates to:
  /// **'Confirm funding'**
  String get paymentConfirmFunding;

  /// No description provided for @paymentSetup.
  ///
  /// In en, this message translates to:
  /// **'Funding setup'**
  String get paymentSetup;

  /// No description provided for @paymentStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get paymentStatusDraft;

  /// No description provided for @paymentStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get paymentStatusActive;

  /// No description provided for @paymentRail.
  ///
  /// In en, this message translates to:
  /// **'Payment rail'**
  String get paymentRail;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Investment amount'**
  String get paymentAmount;

  /// No description provided for @paymentAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount in USD'**
  String get paymentAmountHint;

  /// No description provided for @paymentBelowMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum for this opportunity is {minimum}.'**
  String paymentBelowMinimum(String minimum);

  /// No description provided for @paymentDemoAmount.
  ///
  /// In en, this message translates to:
  /// **'Demo amount can be adjusted before creating the deposit request.'**
  String get paymentDemoAmount;

  /// No description provided for @paymentQuotePaymentAsset.
  ///
  /// In en, this message translates to:
  /// **'Payment asset'**
  String get paymentQuotePaymentAsset;

  /// No description provided for @paymentQuoteAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentQuoteAmount;

  /// No description provided for @paymentQuoteNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get paymentQuoteNetwork;

  /// No description provided for @paymentNetworkAfterRequest.
  ///
  /// In en, this message translates to:
  /// **'Selected after request'**
  String get paymentNetworkAfterRequest;

  /// No description provided for @paymentQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get paymentQuote;

  /// No description provided for @paymentQuoteByBackend.
  ///
  /// In en, this message translates to:
  /// **'Created by backend'**
  String get paymentQuoteByBackend;

  /// No description provided for @paymentNetworkFee.
  ///
  /// In en, this message translates to:
  /// **'Network fee'**
  String get paymentNetworkFee;

  /// No description provided for @paymentFeeByBackend.
  ///
  /// In en, this message translates to:
  /// **'Calculated by backend'**
  String get paymentFeeByBackend;

  /// No description provided for @paymentSettlement.
  ///
  /// In en, this message translates to:
  /// **'Settlement'**
  String get paymentSettlement;

  /// No description provided for @paymentPendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Pending confirmation'**
  String get paymentPendingConfirmation;

  /// No description provided for @paymentConfirmableTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmable financial action'**
  String get paymentConfirmableTitle;

  /// No description provided for @paymentConfirmableBody.
  ///
  /// In en, this message translates to:
  /// **'You are authorizing a crypto-funded BrickShares purchase. Settlement may take network confirmations.'**
  String get paymentConfirmableBody;

  /// No description provided for @paymentCreateRequest.
  ///
  /// In en, this message translates to:
  /// **'Create deposit request'**
  String get paymentCreateRequest;

  /// No description provided for @paymentSubmitProof.
  ///
  /// In en, this message translates to:
  /// **'Submit proof for review'**
  String get paymentSubmitProof;

  /// No description provided for @paymentIncreaseAmount.
  ///
  /// In en, this message translates to:
  /// **'Increase the amount to the opportunity minimum.'**
  String get paymentIncreaseAmount;

  /// No description provided for @paymentDepositCreated.
  ///
  /// In en, this message translates to:
  /// **'Deposit request created'**
  String get paymentDepositCreated;

  /// No description provided for @paymentEnterHash.
  ///
  /// In en, this message translates to:
  /// **'Enter the transaction hash'**
  String get paymentEnterHash;

  /// No description provided for @paymentUploadProof.
  ///
  /// In en, this message translates to:
  /// **'Upload proof of payment'**
  String get paymentUploadProof;

  /// No description provided for @paymentDepositInstructions.
  ///
  /// In en, this message translates to:
  /// **'Deposit instructions'**
  String get paymentDepositInstructions;

  /// No description provided for @paymentWalletAddress.
  ///
  /// In en, this message translates to:
  /// **'Wallet address'**
  String get paymentWalletAddress;

  /// No description provided for @paymentTransactionHash.
  ///
  /// In en, this message translates to:
  /// **'Transaction hash'**
  String get paymentTransactionHash;

  /// No description provided for @paymentHashHint.
  ///
  /// In en, this message translates to:
  /// **'Paste blockchain transaction hash'**
  String get paymentHashHint;

  /// No description provided for @paymentReference.
  ///
  /// In en, this message translates to:
  /// **'Payment reference'**
  String get paymentReference;

  /// No description provided for @paymentReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the transfer ID or reference'**
  String get paymentReferenceHint;

  /// No description provided for @paymentStepQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get paymentStepQuote;

  /// No description provided for @paymentStepSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get paymentStepSend;

  /// No description provided for @paymentStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get paymentStepReview;

  /// No description provided for @paymentCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get paymentCopy;

  /// No description provided for @paymentWalletCopied.
  ///
  /// In en, this message translates to:
  /// **'Wallet address copied'**
  String get paymentWalletCopied;

  /// No description provided for @supportNewRequest.
  ///
  /// In en, this message translates to:
  /// **'New support request'**
  String get supportNewRequest;

  /// No description provided for @supportNoRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'No support requests yet'**
  String get supportNoRequestsTitle;

  /// No description provided for @supportNoRequestsBody.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with the BrickClub team when you need account, KYC, wallet, or investment help.'**
  String get supportNoRequestsBody;

  /// No description provided for @supportSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get supportSendRequest;

  /// No description provided for @supportReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reply to support'**
  String get supportReplyTitle;

  /// No description provided for @supportSendReply.
  ///
  /// In en, this message translates to:
  /// **'Send reply'**
  String get supportSendReply;

  /// No description provided for @supportMessagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} messages'**
  String supportMessagesCount(int count);

  /// No description provided for @supportRequestClosed.
  ///
  /// In en, this message translates to:
  /// **'Request closed'**
  String get supportRequestClosed;

  /// No description provided for @supportReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get supportReply;

  /// No description provided for @supportTalkDirectly.
  ///
  /// In en, this message translates to:
  /// **'Talk to us directly'**
  String get supportTalkDirectly;

  /// No description provided for @supportTalkBody.
  ///
  /// In en, this message translates to:
  /// **'Prefer a quick chat? Reach the BrickClub support team on WhatsApp or Telegram for faster help.'**
  String get supportTalkBody;

  /// No description provided for @supportNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get supportNoMessagesYet;

  /// No description provided for @supportTeamName.
  ///
  /// In en, this message translates to:
  /// **'BrickClub support'**
  String get supportTeamName;

  /// No description provided for @supportYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get supportYou;

  /// No description provided for @supportSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get supportSubject;

  /// No description provided for @supportSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'What do you need help with?'**
  String get supportSubjectHint;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get supportMessage;

  /// No description provided for @supportMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type your message'**
  String get supportMessageHint;

  /// No description provided for @supportEnterSubject.
  ///
  /// In en, this message translates to:
  /// **'Enter a subject'**
  String get supportEnterSubject;

  /// No description provided for @supportEnterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a message'**
  String get supportEnterMessage;

  /// No description provided for @supportMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get supportMessageSent;

  /// No description provided for @supportCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String supportCouldNotOpen(String url);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @notificationsNone.
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get notificationsNone;

  /// No description provided for @profileInMore.
  ///
  /// In en, this message translates to:
  /// **'Profile is in More'**
  String get profileInMore;

  /// No description provided for @investmentCardCryptoFunding.
  ///
  /// In en, this message translates to:
  /// **'Funding'**
  String get investmentCardCryptoFunding;

  /// No description provided for @commonShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get commonShowPassword;

  /// No description provided for @commonHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get commonHidePassword;

  /// No description provided for @errAuthEmulatorUnreachable.
  ///
  /// In en, this message translates to:
  /// **'The app could not reach the Firebase Auth emulator. Rebuild the debug app and make sure the Firebase emulators are running.'**
  String get errAuthEmulatorUnreachable;

  /// No description provided for @errInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get errInvalidEmail;

  /// No description provided for @errMissingEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get errMissingEmail;

  /// No description provided for @errMissingPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get errMissingPassword;

  /// No description provided for @errUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account exists for that email.'**
  String get errUserNotFound;

  /// No description provided for @errWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get errWrongPassword;

  /// No description provided for @errEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for that email.'**
  String get errEmailInUse;

  /// No description provided for @errWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Use a stronger password with at least 6 characters.'**
  String get errWeakPassword;

  /// No description provided for @errOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Email sign in is not enabled yet. Contact support.'**
  String get errOperationNotAllowed;

  /// No description provided for @errUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled. Contact support for help.'**
  String get errUserDisabled;

  /// No description provided for @errTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment before trying again.'**
  String get errTooManyRequests;

  /// No description provided for @errNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not connect. Check your internet and try again.'**
  String get errNetworkFailed;

  /// No description provided for @errRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in again before making this change.'**
  String get errRequiresRecentLogin;

  /// No description provided for @errExpiredActionCode.
  ///
  /// In en, this message translates to:
  /// **'This link has expired. Request a new one and try again.'**
  String get errExpiredActionCode;

  /// No description provided for @errInvalidActionCode.
  ///
  /// In en, this message translates to:
  /// **'This link is no longer valid. Request a new one and try again.'**
  String get errInvalidActionCode;

  /// No description provided for @errAccountRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not complete that account request. Please try again.'**
  String get errAccountRequestFailed;

  /// No description provided for @errResetUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Password reset email is temporarily unavailable. Please try again shortly.'**
  String get errResetUnavailable;

  /// No description provided for @errResetNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Password reset is not available right now.'**
  String get errResetNotAvailable;

  /// No description provided for @errResetFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not send the reset email. Please try again.'**
  String get errResetFailed;

  /// No description provided for @errSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to continue.'**
  String get errSignInAgain;

  /// No description provided for @errAdminNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Your account does not have permission to do that.'**
  String get errAdminNoPermission;

  /// No description provided for @errEmailEnvUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Email sending is not available in this environment.'**
  String get errEmailEnvUnavailable;

  /// No description provided for @errAddEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Add an email address to your account first.'**
  String get errAddEmailFirst;

  /// No description provided for @errPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get errPermissionDenied;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// No description provided for @errKycInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the SMS code from the emulator.'**
  String get errKycInvalidCode;

  /// No description provided for @errKycCredentialInUse.
  ///
  /// In en, this message translates to:
  /// **'That phone number is already linked to another account.'**
  String get errKycCredentialInUse;

  /// No description provided for @errKycTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many verification attempts. Try again later.'**
  String get errKycTooManyRequests;

  /// No description provided for @errKycPhoneFailed.
  ///
  /// In en, this message translates to:
  /// **'Phone verification failed. Please try again.'**
  String get errKycPhoneFailed;

  /// No description provided for @errKycSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to continue with KYC.'**
  String get errKycSignInAgain;

  /// No description provided for @errKycNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to update this KYC profile.'**
  String get errKycNoPermission;

  /// No description provided for @errKycUnavailable.
  ///
  /// In en, this message translates to:
  /// **'KYC services are temporarily unavailable. Please try again shortly.'**
  String get errKycUnavailable;

  /// No description provided for @errKycDeadline.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please check your connection and try again.'**
  String get errKycDeadline;

  /// No description provided for @errKycStorageUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to upload this document.'**
  String get errKycStorageUnauthorized;

  /// No description provided for @errKycStorageCanceled.
  ///
  /// In en, this message translates to:
  /// **'Document upload was cancelled.'**
  String get errKycStorageCanceled;

  /// No description provided for @errKycStorageRetry.
  ///
  /// In en, this message translates to:
  /// **'The upload took too long. Please check your connection and try again.'**
  String get errKycStorageRetry;

  /// No description provided for @errKycStorageQuota.
  ///
  /// In en, this message translates to:
  /// **'Document uploads are temporarily unavailable. Please try again later.'**
  String get errKycStorageQuota;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @enumAssetRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get enumAssetRealEstate;

  /// No description provided for @enumAssetReit.
  ///
  /// In en, this message translates to:
  /// **'REIT'**
  String get enumAssetReit;

  /// No description provided for @enumAssetEtf.
  ///
  /// In en, this message translates to:
  /// **'ETF'**
  String get enumAssetEtf;

  /// No description provided for @enumAssetIndex.
  ///
  /// In en, this message translates to:
  /// **'Index Fund'**
  String get enumAssetIndex;

  /// No description provided for @enumAssetAlternative.
  ///
  /// In en, this message translates to:
  /// **'Alternative'**
  String get enumAssetAlternative;

  /// No description provided for @enumRiskConservative.
  ///
  /// In en, this message translates to:
  /// **'Conservative'**
  String get enumRiskConservative;

  /// No description provided for @enumRiskBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get enumRiskBalanced;

  /// No description provided for @enumRiskGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get enumRiskGrowth;

  /// No description provided for @walletAddFundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add funds to wallet'**
  String get walletAddFundsTitle;

  /// No description provided for @walletAddFundsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top up your spendable balance'**
  String get walletAddFundsSubtitle;

  /// No description provided for @investPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Start an investment'**
  String get investPlanTitle;

  /// No description provided for @investPlanNonePanel.
  ///
  /// In en, this message translates to:
  /// **'No investment plans are available for this asset yet. Please check back soon.'**
  String get investPlanNonePanel;

  /// No description provided for @investPlanAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available to invest'**
  String get investPlanAvailable;

  /// No description provided for @investPlanAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount to invest'**
  String get investPlanAmount;

  /// No description provided for @investPlanAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Between {min} and {max}'**
  String investPlanAmountHint(String min, String max);

  /// No description provided for @investPlanOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount between {min} and {max}.'**
  String investPlanOutOfRange(String min, String max);

  /// No description provided for @investPlanInsufficient.
  ///
  /// In en, this message translates to:
  /// **'This is more than your wallet balance. Add funds first.'**
  String get investPlanInsufficient;

  /// No description provided for @investPlanBandApplied.
  ///
  /// In en, this message translates to:
  /// **'Plan tier: {range}'**
  String investPlanBandApplied(String range);

  /// No description provided for @investPlanDuration.
  ///
  /// In en, this message translates to:
  /// **'Lock duration'**
  String get investPlanDuration;

  /// No description provided for @investPlanPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get investPlanPrincipal;

  /// No description provided for @investPlanRate.
  ///
  /// In en, this message translates to:
  /// **'Return rate'**
  String get investPlanRate;

  /// No description provided for @investPlanProfit.
  ///
  /// In en, this message translates to:
  /// **'Projected profit'**
  String get investPlanProfit;

  /// No description provided for @investPlanPayout.
  ///
  /// In en, this message translates to:
  /// **'Total at maturity'**
  String get investPlanPayout;

  /// No description provided for @investPlanMaturity.
  ///
  /// In en, this message translates to:
  /// **'Matures on'**
  String get investPlanMaturity;

  /// No description provided for @investPlanDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Profit is credited to your wallet as a lump sum when the plan matures.'**
  String get investPlanDisclaimer;

  /// No description provided for @investPlanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm investment'**
  String get investPlanConfirm;

  /// No description provided for @investPlanSuccess.
  ///
  /// In en, this message translates to:
  /// **'Investment started. You will receive {payout} at maturity.'**
  String investPlanSuccess(String payout);

  /// No description provided for @portfolioExpectedProfit.
  ///
  /// In en, this message translates to:
  /// **'Expected profit at maturity: {amount}'**
  String portfolioExpectedProfit(String amount);

  /// No description provided for @portfolioPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Active investment plans'**
  String get portfolioPlansTitle;

  /// No description provided for @portfolioPlanSummary.
  ///
  /// In en, this message translates to:
  /// **'{rate} for {duration} · matures {date}'**
  String portfolioPlanSummary(String rate, String duration, String date);

  /// No description provided for @portfolioPlanMatures.
  ///
  /// In en, this message translates to:
  /// **'Pays {payout} at maturity on {date}'**
  String portfolioPlanMatures(String payout, String date);
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
