// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'Lugha';

  @override
  String get languageScreenTitle => 'Lugha';

  @override
  String get languageHeading => 'Lugha ya kuonyesha';

  @override
  String get languageDescription =>
      'Chagua lugha ambayo BrickClub hutumia kwenye kifaa hiki.';

  @override
  String get languageSystemDefault => 'Chaguomsingi la mfumo';

  @override
  String get commonEmail => 'Barua pepe';

  @override
  String get commonEmailHint => 'wewe@mfano.com';

  @override
  String get commonPassword => 'Nenosiri';

  @override
  String get authConnecting => 'Inaunganisha…';

  @override
  String get signInWelcomeTitle => 'Karibu tena';

  @override
  String get signInAdminTitle => 'Kuingia kwa msimamizi';

  @override
  String get signInMemberSubtitle =>
      'Endelea kwenye kasha lako la BrickShares.';

  @override
  String get signInAdminSubtitle =>
      'Fikia shughuli za watumiaji, mali na malipo ya sarafu-fiche.';

  @override
  String get signInPasswordHint => 'Weka nenosiri lako';

  @override
  String get signInForgotPassword => 'Umesahau nenosiri?';

  @override
  String get signInProgress => 'Inaingia…';

  @override
  String get signInOpenAdminDashboard => 'Fungua dashibodi ya msimamizi';

  @override
  String get signInSubmit => 'Ingia kwa usalama';

  @override
  String get signInGoogleAdmin => 'Endelea kama msimamizi kwa Google';

  @override
  String get signInGoogle => 'Endelea na Google';

  @override
  String get signInPhone => 'Endelea na simu';

  @override
  String get signInUseMember => 'Tumia kuingia kwa mwanachama';

  @override
  String get signInUseAdmin => 'Ingia kama msimamizi';

  @override
  String get signInCreateAccount => 'Fungua akaunti ya BrickClub';

  @override
  String get signInGoogleNoAdmin =>
      'Akaunti hii ya Google haina ufikiaji wa msimamizi.';

  @override
  String get signInNoAdmin => 'Akaunti hii haina ufikiaji wa msimamizi.';

  @override
  String get signInResetSent => 'Maelekezo ya kuweka upya nenosiri yametumwa';

  @override
  String get signInStoryTitle => 'Umiliki, sasa\nunapatikana zaidi.';

  @override
  String get signInStoryBody =>
      'Kagua fursa zilizothibitishwa, lipa kwa uhakika, na uweke kila mali mbele ya macho yako.';

  @override
  String get signUpIntro =>
      'Fungua akaunti yako ya BrickShares. Uthibitishaji wa kasha na KYC vinafuata.';

  @override
  String get signUpCreateAccount => 'Fungua akaunti';

  @override
  String get signUpLegalNamesHint =>
      'Tumia majina yako rasmi kama yanavyoonekana kwenye kitambulisho chako.';

  @override
  String get signUpFirstName => 'Jina la kwanza';

  @override
  String get signUpFirstNameHint => 'Jina rasmi la kwanza';

  @override
  String get signUpLastName => 'Jina la ukoo';

  @override
  String get signUpLastNameHint => 'Jina rasmi la ukoo';

  @override
  String get signUpPasswordHint => 'Tengeneza nenosiri';

  @override
  String get signUpConfirmPassword => 'Thibitisha nenosiri';

  @override
  String get signUpConfirmPasswordHint => 'Thibitisha nenosiri lako';

  @override
  String get signUpAgree =>
      'Ninakubali masharti, ufichuzi wa hatari, na arifa za uthibitisho wa malipo.';

  @override
  String get signUpProgress => 'Inafungua akaunti…';

  @override
  String get signUpGoogle => 'Jisajili na Google';

  @override
  String get signUpDisclosure =>
      'Shughuli za kifedha zinahitaji KYC na usanidi wa kasha lililothibitishwa baada ya kufungua akaunti.';

  @override
  String get signUpHaveAccount => 'Tayari una akaunti? Ingia';

  @override
  String get phoneTitle => 'Ingia kwa simu';

  @override
  String get phoneOtpTitle => 'Weka msimbo wa uthibitisho';

  @override
  String get phoneSubtitle =>
      'Weka nambari yako ya simu na msimbo wa nchi (mf. +1 415 555 2671).';

  @override
  String phoneOtpSubtitle(String phone) {
    return 'Tumetuma msimbo wa tarakimu 6 kwa $phone.';
  }

  @override
  String get phoneHint => '+1 415 555 2671';

  @override
  String get phoneCodeHint => '000000';

  @override
  String get phoneSendingCode => 'Inatuma msimbo…';

  @override
  String get phoneSendCode => 'Tuma msimbo wa uthibitisho';

  @override
  String get phoneVerifying => 'Inathibitisha…';

  @override
  String get phoneConfirmCode => 'Thibitisha msimbo';

  @override
  String get phoneUseDifferentNumber => 'Tumia nambari nyingine';

  @override
  String get installIosTitle => 'Sakinisha kwenye iPhone au iPad';

  @override
  String get installIosIntro =>
      'Ongeza BrickClub kwenye skrini yako ya kwanza moja kwa moja kutoka Safari — bila kuhitaji App Store.';

  @override
  String get installIosStep1 =>
      'Gusa kitufe cha Kushiriki kwenye upau wa vidhibiti wa Safari.';

  @override
  String get installIosStep2 =>
      'Teleza chini na uchague «Ongeza kwenye Skrini ya Kwanza».';

  @override
  String get installIosStep3 =>
      'Gusa «Ongeza» — BrickClub itaonekana kwenye skrini yako ya kwanza.';

  @override
  String get installAndroidTitle => 'Sakinisha kwenye Android';

  @override
  String get installAndroidIntro =>
      'Ongeza BrickClub kwenye kifaa chako kwa mguso michache kutoka kwa kivinjari chako.';

  @override
  String get installAndroidStep1 =>
      'Fungua menyu ya kivinjari (⋮ kwenye kona ya juu).';

  @override
  String get installAndroidStep2 =>
      'Gusa «Sakinisha programu» au «Ongeza kwenye Skrini ya Kwanza».';

  @override
  String get installAndroidStep3 =>
      'Thibitisha — BrickClub itaonekana kwenye droo yako ya programu.';

  @override
  String get installDesktopTitle => 'Sakinisha kwenye kompyuta';

  @override
  String get installDesktopIntro =>
      'Sakinisha BrickClub kama programu kutoka Chrome au Edge.';

  @override
  String get installDesktopStep1 =>
      'Bofya aikoni ya kusakinisha kwenye upau wa anwani, au fungua menyu ya kivinjari.';

  @override
  String get installDesktopStep2 =>
      'Chagua «Sakinisha» ili kufungua BrickClub kwenye dirisha lake mwenyewe.';

  @override
  String get installGotIt => 'Nimeelewa';

  @override
  String get installAlready =>
      'BrickClub tayari imesakinishwa kwenye kifaa hiki.';

  @override
  String get installInstalling => 'Inasakinisha BrickClub kwenye kifaa chako…';

  @override
  String get installDismissed =>
      'Usakinishaji umeghairiwa. Unaweza kusakinisha wakati wowote.';

  @override
  String get navFeatures => 'Vipengele';

  @override
  String get navHowItWorks => 'Jinsi inavyofanya kazi';

  @override
  String get navTestimonials => 'Ushuhuda';

  @override
  String get landingSignIn => 'Ingia';

  @override
  String get landingSignUp => 'Jisajili';

  @override
  String get landingJoin => 'Jiunge';

  @override
  String get landingCreateAccount => 'Fungua akaunti';

  @override
  String get heroTitle => 'Miliki zaidi ya\nndoto.';

  @override
  String get heroBody =>
      'Jenga umiliki halisi kupitia BrickShares zilizothibitishwa na zinazoungwa mkono na mali isiyohamishika, ukiwa na utendaji wa uwazi na malipo ya sarafu-fiche yanayoaminika kutoka kwa programu moja salama.';

  @override
  String get heroInstall => 'Sakinisha programu';

  @override
  String get heroExplore => 'Chunguza BrickShares';

  @override
  String get proofVerifiedAssets => 'Mali zilizothibitishwa';

  @override
  String get proofTrustedSettlement => 'Malipo yanayoaminika';

  @override
  String get proofClearPerformance => 'Utendaji ulio wazi';

  @override
  String get previewPortfolioValue => 'Thamani ya kasha';

  @override
  String get previewMinimum => 'Kiwango cha chini';

  @override
  String get previewTargetReturn => 'Faida lengwa';

  @override
  String get heroCardTargetReturn => 'Faida lengwa ya mwaka';

  @override
  String get assetVerifiedBadge => 'MALI ILIYOTHIBITISHWA';

  @override
  String get assetSampleDescription => 'Mali ya makazi inayozalisha mapato';

  @override
  String get assetFunded => 'Imefadhiliwa';

  @override
  String get trustDueDiligence => 'UCHUNGUZI WA MALI ISIYOHAMISHIKA';

  @override
  String get trustKycVerified => 'WANACHAMA WALIOTHIBITISHWA KWA KYC';

  @override
  String get trustUsdtSettlement => 'MALIPO KWA USDT';

  @override
  String get trustOwnershipRecords => 'REKODI WAZI ZA UMILIKI';

  @override
  String get statTargetReturn => 'Wastani wa faida lengwa';

  @override
  String get statMinimum => 'Kiwango cha chini cha kuanza';

  @override
  String get statSettlement => 'Malipo kwenye mnyororo';

  @override
  String get statVisibility => 'Uonekano wa kasha';

  @override
  String get howTitle => 'Kutoka kujisajili hadi umiliki.';

  @override
  String get howSubtitle =>
      'Njia iliyo wazi iliyoundwa kwa wawekezaji wanaotaka uhakika katika kila hatua.';

  @override
  String get howStep1Title => 'Fungua na uthibitishe';

  @override
  String get howStep1Body =>
      'Fungua akaunti yako, kamilisha KYC, na uunganishe kasha lililothibitishwa.';

  @override
  String get howStep2Title => 'Chagua BrickShares';

  @override
  String get howStep2Body =>
      'Kagua mali zilizothibitishwa, faida lengwa, hatari, na masharti ya umiliki.';

  @override
  String get howStep3Title => 'Fadhili na ufuatilie';

  @override
  String get howStep3Body =>
      'Lipa kwa usalama kwa sarafu-fiche zinazotumika na ufuatilie kasha lako.';

  @override
  String get featuresTitle => 'Imeundwa kwa uwazi,\nsi uchezaji wa bahati.';

  @override
  String get featuresBody =>
      'Kila fursa huweka mbele taarifa muhimu: muundo wa umiliki, uthibitishaji wa mali, faida lengwa, hatari, mtandao wa ufadhili, na hali ya malipo.';

  @override
  String get feature1 => 'Nyaraka za mali zilizothibitishwa';

  @override
  String get feature2 => 'Bei za sarafu-fiche na ada za mtandao zilizo wazi';

  @override
  String get feature3 => 'Uthibitisho kabla ya kila kitendo cha kifedha';

  @override
  String get testimonialsTitle => 'Imejengwa juu ya imani ya wawekezaji.';

  @override
  String get testimonialsSubtitle =>
      'Kile ambacho wanachama wa awali wa BrickClub wanathamini zaidi kuhusu uzoefu.';

  @override
  String get testimonial1Quote =>
      'BrickClub hurahisisha kuelewa maelezo muhimu. Najua ninachomiliki, jinsi kinavyofanya, na kinachotokea kabla ya kufadhili.';

  @override
  String get testimonial1Role => 'Mfanyabiashara, London';

  @override
  String get testimonial2Quote =>
      'Mchakato wa uthibitishaji na uthibitisho ulinipa imani. Inahisi kama jukwaa la uwekezaji la kweli, si njia nyingine ya mkato ya sarafu-fiche.';

  @override
  String get testimonial2Role => 'Kiongozi wa bidhaa, Singapore';

  @override
  String get testimonial3Quote =>
      'Naweza kuanza kwa kiasi cha kawaida na bado kupata mali ambazo kwa kawaida ningezitazama kutoka nje tu.';

  @override
  String get testimonial3Role => 'Mshauri, Dubai';

  @override
  String get ctaBadge => 'ANZA NDANI YA DAKIKA';

  @override
  String get ctaTitle => 'Mali yako inayofuata inaweza kuanzia hapa.';

  @override
  String get ctaBody =>
      'Sakinisha BrickClub, fungua akaunti yako, na uchunguze BrickShares zilizothibitishwa zilizoundwa kwa umiliki wa muda mrefu.';

  @override
  String get ctaHaveAccount => 'Tayari nina akaunti';

  @override
  String get ctaSecureKyc => 'KYC salama';

  @override
  String get ctaFreeToBrowse => 'Bure kuvinjari';

  @override
  String get ctaVerifiedOnly => 'Mali zilizothibitishwa pekee';

  @override
  String get footerCopyright => '© 2026 BrickClub';
}
