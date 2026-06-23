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

  @override
  String get commonViewAll => 'Tazama zote';

  @override
  String get commonCancel => 'Ghairi';

  @override
  String get navInvest => 'Wekeza';

  @override
  String get navWallet => 'Pochi';

  @override
  String get navPortfolio => 'Kasha';

  @override
  String get navProfile => 'Wasifu';

  @override
  String get kycGateTitle => 'Kamilisha KYC kwanza';

  @override
  String kycGateBody(String status) {
    return 'Hali: $status. Ununuzi, utoaji, mabadiliko ya pochi, na malipo ya sarafu-fiche hufunguliwa baada ya kuidhinishwa.';
  }

  @override
  String get kycGateViewStatus => 'Tazama hali ya KYC';

  @override
  String get kycGateComplete => 'Kamilisha KYC';

  @override
  String get homeFeaturedOpportunity => 'Fursa iliyoangaziwa';

  @override
  String get homeNoLiveTitle => 'Bado hakuna BrickShares zinazoendelea';

  @override
  String get homeNoLiveBody =>
      'Mali zilizochapishwa na kuthibitishwa zitaonekana hapa.';

  @override
  String get homeViewInvest => 'Tazama uwekezaji';

  @override
  String get homeYourHoldings => 'Umiliki wako';

  @override
  String get homeRecentActivity => 'Shughuli za hivi karibuni';

  @override
  String get holdingsEmptyTitle => 'Bado hakuna umiliki';

  @override
  String get holdingsEmptyHome =>
      'Amana zilizothibitishwa zitaonekana hapa kama BrickShares.';

  @override
  String get activityEmptyTitle => 'Bado hakuna shughuli';

  @override
  String get activityEmptyBody =>
      'Maombi ya amana na masasisho ya malipo yataonekana hapa.';

  @override
  String get dashboardErrorTitle => 'Imeshindwa kupakia data ya akaunti';

  @override
  String get dashboardErrorBody => 'Kagua muunganisho wa seva na ujaribu tena.';

  @override
  String get investSubtitle =>
      'Chunguza BrickShares za mali nyingi zilizothibitishwa';

  @override
  String get investSearchHint => 'Tafuta kwa jina, eneo, au aina ya mali';

  @override
  String investAvailable(int count) {
    return 'Zinazopatikana $count';
  }

  @override
  String get investFilteredIncome => 'BrickShares za mapato\nzilizochujwa';

  @override
  String investOpportunitiesCount(int count) {
    return 'Fursa $count';
  }

  @override
  String get investLoadingOpportunities => 'Inapakia fursa';

  @override
  String get investFiltersAction => 'Vichujio';

  @override
  String get investNoMatchTitle => 'Hakuna BrickShares zinazolingana';

  @override
  String get investNoMatchEmpty =>
      'Mali zilizothibitishwa zilizochapishwa na msimamizi zitaonekana hapa.';

  @override
  String investNoMatchSearch(String query) {
    return 'Hakuna BrickShares zinazolingana na «$query». Jaribu utafutaji mwingine au rekebisha vichujio.';
  }

  @override
  String get investNoMatchFilters =>
      'Jaribu aina nyingine ya mali, kiwango cha hatari, au njia ya malipo.';

  @override
  String get investResetFilters => 'Weka upya vichujio';

  @override
  String get walletCryptoActivity => 'Shughuli za maagizo ya sarafu-fiche';

  @override
  String get walletFundingTitle => 'Utayari wa ufadhili wa sarafu-fiche';

  @override
  String get walletFundingBody =>
      'Ongeza pochi iliyothibitishwa kabla ya kutuma fedha. Mtandao, ada, mwisho wa bei, na hali ya malipo huonyeshwa kabla ya uthibitisho.';

  @override
  String get walletAddWallet => 'Ongeza pochi iliyothibitishwa';

  @override
  String get walletVerificationStarted => 'Uthibitishaji wa pochi umeanza';

  @override
  String get walletSettlementTitle => 'Uthibitisho wa malipo unahitajika';

  @override
  String get walletSettlementBody =>
      'Ununuzi, utoaji, na mabadiliko ya pochi yanahitaji uthibitisho wa mwisho.';

  @override
  String get walletVerifiedBalance => 'Salio la pochi iliyothibitishwa';

  @override
  String get portfolioCurrentValue => 'Thamani ya sasa ya kasha';

  @override
  String get portfolioInvested => 'Iliyowekezwa';

  @override
  String get portfolioProfitLoss => 'Faida / hasara';

  @override
  String get portfolioReturn => 'Faida';

  @override
  String portfolioDividends(String amount) {
    return 'Gawio lililopokelewa: $amount';
  }

  @override
  String get portfolioHoldings => 'Umiliki';

  @override
  String get portfolioHoldingsEmptyBody =>
      'Uwekezaji ulioidhinishwa unaonekana hapa kiotomatiki.';

  @override
  String get portfolioAllocation => 'Mgawanyo';

  @override
  String get portfolioAllocationEmptyTitle => 'Bado hakuna mgawanyo';

  @override
  String get portfolioAllocationEmptyBody =>
      'Mchanganyiko wa mali zako utaonekana baada ya amana kuthibitishwa.';

  @override
  String portfolioInvestedOwnership(String invested, String ownership) {
    return 'Iliyowekezwa $invested · umiliki $ownership';
  }

  @override
  String get profileSettings => 'Mipangilio';

  @override
  String profileThemeSubtitle(String mode) {
    return 'Mandhari $mode';
  }

  @override
  String get profileSecurityTitle => 'Usalama na faragha';

  @override
  String get profileSecuritySubtitle => 'Pochi iliyothibitishwa na bayometriki';

  @override
  String get profileDocumentsTitle => 'Nyaraka';

  @override
  String get profileDocumentsSubtitle =>
      'Taarifa za akaunti, ufichuzi wa hatari';

  @override
  String profileRowOpened(String title) {
    return '$title imefunguliwa';
  }

  @override
  String get profileSupport => 'Msaada';

  @override
  String get profileSupportSubtitle => 'Tuma ujumbe kwa timu ya BrickClub';

  @override
  String get profileLogout => 'Toka';

  @override
  String get profileLogoutConfirmTitle => 'Utoke?';

  @override
  String get profileLogoutConfirmBody =>
      'Utahitaji kuingia tena ili kufikia akaunti yako.';

  @override
  String get profileDefaultName => 'Mwanachama wa BrickClub';

  @override
  String get profileDefaultSubtitle => 'Maelezo ya akaunti yako na BrickShares';

  @override
  String get commonRetry => 'Try again';

  @override
  String get profileReferral => 'Refer & earn';

  @override
  String get profileReferralSubtitle => 'Invite friends and earn commission';

  @override
  String get referralScreenTitle => 'Refer & earn';

  @override
  String get referralHeadline => 'Invite friends, earn commission';

  @override
  String referralHowItWorksBody(String rate) {
    return 'Share your code. When someone you invited makes an investment, you earn $rate of the amount they invest — credited straight to your wallet.';
  }

  @override
  String get referralYourCodeTitle => 'Your referral code';

  @override
  String get referralCopyCode => 'Copy code';

  @override
  String get referralCopied => 'Referral code copied';

  @override
  String get referralLinkCopied => 'Invite link copied';

  @override
  String get referralShareInvite => 'Share invite';

  @override
  String get referralFriendsJoined => 'Friends joined';

  @override
  String get referralTotalEarned => 'Total earned';

  @override
  String referralPaidToWalletNote(String rate) {
    return 'You earn $rate of every investment your referrals make, paid to your wallet.';
  }

  @override
  String get referralDisabledNote =>
      'Referral rewards are currently paused. Your code still works — earnings resume when rewards are switched back on.';

  @override
  String get referralRecentEarningsTitle => 'Recent earnings';

  @override
  String get referralNoEarningsYet =>
      'No referral earnings yet. Share your code to get started.';

  @override
  String referralCommissionSubtitle(String rate, String amount) {
    return '$rate of a $amount investment';
  }

  @override
  String get referralLoadError =>
      'We couldn\'t load your referral details. Please try again.';

  @override
  String get signUpReferralCode => 'Referral code (optional)';

  @override
  String get signUpReferralCodeHint => 'Enter a friend\'s code';

  @override
  String get themeScreenTitle => 'Mandhari';

  @override
  String get themeAppearance => 'Mwonekano';

  @override
  String get themeAppearanceDescription =>
      'Chagua jinsi BrickClub inavyoonekana kwenye kifaa hiki.';

  @override
  String get themeLight => 'Angavu';

  @override
  String get themeDark => 'Giza';

  @override
  String get themeSystemDescription => 'Fuata kifaa hiki kiotomatiki.';

  @override
  String get themeLightDescription =>
      'Tumia kiolesura angavu chenye maandishi meusi.';

  @override
  String get themeDarkDescription =>
      'Tumia kiolesura cha giza cha kawaida cha BrickClub.';

  @override
  String get commonSending => 'Inatuma…';

  @override
  String get commonSubmitting => 'Inawasilisha…';

  @override
  String get filtersAssetClass => 'Aina ya mali';

  @override
  String get filtersRiskLevel => 'Kiwango cha hatari';

  @override
  String get filtersPaymentMethod => 'Njia ya malipo';

  @override
  String get filtersReset => 'Weka upya';

  @override
  String filtersShow(int count) {
    return 'Onyesha $count';
  }

  @override
  String get successTitle => 'Uthibitisho umewasilishwa';

  @override
  String get successBody =>
      'Uthibitisho wako wa malipo unasubiri uhakiki wa msimamizi. Tutakujulisha baada ya ukaguzi.';

  @override
  String get successSettlementStatus => 'Hali ya malipo';

  @override
  String get successViewPortfolio => 'Tazama kasha';

  @override
  String get detailVerifiedDocs => 'Nyaraka zilizothibitishwa';

  @override
  String detailAssetLine(String assetClass, String location) {
    return '$assetClass BrickShares | $location';
  }

  @override
  String get detailLiquidity => 'Ukwasi';

  @override
  String get detailFundingStatus => 'Hali ya ufadhili';

  @override
  String detailFundedPercent(String percent) {
    return 'Imefadhiliwa $percent%';
  }

  @override
  String get detailFundingNote =>
      'Njia za malipo zinazotumika na mwisho wa bei huonyeshwa kabla ya uthibitisho wa malipo.';

  @override
  String get detailInvestButton => 'Wekeza kwa ufadhili wa sarafu-fiche';

  @override
  String get kycStatusApproved => 'Shughuli za kifedha zimefunguliwa.';

  @override
  String get kycStatusSubmitted => 'Nyaraka zako zinakaguliwa.';

  @override
  String get kycStatusRejectedDefault => 'Kagua ombi na uwasilishe tena.';

  @override
  String get kycStatusDefault =>
      'Inahitajika kabla ya ununuzi na mabadiliko ya pochi.';

  @override
  String get kycChipPhone => 'Simu';

  @override
  String get kycChipIdentity => 'Utambulisho';

  @override
  String get kycChipOk => 'Sawa';

  @override
  String get kycChipNeeded => 'Inahitajika';

  @override
  String get kycViewDetails => 'Tazama maelezo ya KYC';

  @override
  String get kycVerifyIdentity => 'Thibitisha utambulisho';

  @override
  String get kycFullName => 'Jina kamili rasmi';

  @override
  String get kycFullNameHint =>
      'Jina kama linavyoonekana kwenye kitambulisho chako';

  @override
  String get kycDob => 'Tarehe ya kuzaliwa';

  @override
  String get kycSelectDate => 'Chagua tarehe';

  @override
  String get kycGovId => 'Kitambulisho cha serikali au pasipoti';

  @override
  String get kycUploadId => 'Pakia hati ya kitambulisho';

  @override
  String get kycSelfie => 'Selfie / uthibitisho wa uso';

  @override
  String get kycCaptureSelfie => 'Piga selfie';

  @override
  String get kycAddressProof => 'Uthibitisho wa anwani halisi';

  @override
  String get kycUploadAddress => 'Pakia bili ya huduma au mkataba wa kukodi';

  @override
  String get kycPhoneVerification => 'Uthibitisho wa simu';

  @override
  String get kycSendCode => 'Tuma msimbo';

  @override
  String get kycVerificationCodeHint => 'Msimbo wa uthibitisho';

  @override
  String get kycEmailVerification => 'Uthibitisho wa barua pepe';

  @override
  String get kycEmailVerified => 'Barua pepe imethibitishwa';

  @override
  String get kycEmailNotVerified => 'Barua pepe haijathibitishwa';

  @override
  String get kycSendEmail => 'Tuma barua pepe';

  @override
  String get kycSubmitForReview => 'Wasilisha kwa ukaguzi';

  @override
  String get kycEmulatorNote =>
      'Misimbo ya simu inaonekana kwenye emuleta ya Firebase Auth. Barua pepe za maendeleo zinaonekana katika Mailpit.';

  @override
  String get kycEmailSent => 'Barua pepe ya uthibitisho imetumwa';

  @override
  String get kycEnterPhoneFirst => 'Weka nambari yako ya simu kwanza';

  @override
  String get kycCodeSent =>
      'Msimbo umetumwa. Angalia emuleta ya Firebase Auth.';

  @override
  String get kycSubmitted => 'KYC imewasilishwa kwa ukaguzi wa kiotomatiki';

  @override
  String get kycMissingName => 'Weka jina lako rasmi';

  @override
  String get kycMissingDob => 'Chagua tarehe yako ya kuzaliwa';

  @override
  String get kycMissingId => 'Pakia kitambulisho chako au pasipoti';

  @override
  String get kycMissingSelfie => 'Piga selfie';

  @override
  String get kycMissingAddress => 'Pakia uthibitisho wa anwani';

  @override
  String get kycMissingPhone => 'Weka nambari yako ya simu';

  @override
  String get kycInvalidPhone =>
      'Weka nambari yako ya simu kwa muundo wa kimataifa, mf. +12025550190.';

  @override
  String get kycMissingCode => 'Weka msimbo wa uthibitisho wa simu';

  @override
  String get kycUpdateFailed =>
      'Hatukuweza kusasisha maelezo yako ya KYC. Tafadhali jaribu tena.';

  @override
  String get paymentConfirmFunding => 'Thibitisha ufadhili';

  @override
  String get paymentSetup => 'Usanidi wa ufadhili wa sarafu-fiche';

  @override
  String get paymentStatusDraft => 'Rasimu';

  @override
  String get paymentStatusActive => 'Inaendelea';

  @override
  String get paymentRail => 'Njia ya malipo';

  @override
  String get paymentAmount => 'Kiasi cha uwekezaji';

  @override
  String get paymentAmountHint => 'Kiasi kwa USD';

  @override
  String paymentBelowMinimum(String minimum) {
    return 'Kiwango cha chini cha fursa hii ni $minimum.';
  }

  @override
  String get paymentDemoAmount =>
      'Kiasi cha onyesho kinaweza kurekebishwa kabla ya kuunda ombi la amana.';

  @override
  String get paymentQuotePaymentAsset => 'Mali ya malipo';

  @override
  String get paymentQuoteAmount => 'Kiasi';

  @override
  String get paymentQuoteNetwork => 'Mtandao';

  @override
  String get paymentNetworkAfterRequest => 'Huchaguliwa baada ya ombi';

  @override
  String get paymentQuote => 'Bei';

  @override
  String get paymentQuoteByBackend => 'Imeundwa na seva';

  @override
  String get paymentNetworkFee => 'Ada ya mtandao';

  @override
  String get paymentFeeByBackend => 'Imehesabiwa na seva';

  @override
  String get paymentSettlement => 'Malipo';

  @override
  String get paymentPendingConfirmation => 'Inasubiri uthibitisho';

  @override
  String get paymentConfirmableTitle =>
      'Kitendo cha kifedha kinachoweza kuthibitishwa';

  @override
  String get paymentConfirmableBody =>
      'Unaidhinisha ununuzi wa BrickShares uliofadhiliwa kwa sarafu-fiche. Malipo yanaweza kuhitaji uthibitisho wa mtandao.';

  @override
  String get paymentCreateRequest => 'Unda ombi la amana';

  @override
  String get paymentSubmitProof => 'Wasilisha uthibitisho kwa ukaguzi';

  @override
  String get paymentIncreaseAmount =>
      'Ongeza kiasi hadi kiwango cha chini cha fursa.';

  @override
  String get paymentDepositCreated => 'Ombi la amana limeundwa';

  @override
  String get paymentEnterHash => 'Weka hashi ya muamala';

  @override
  String get paymentUploadProof => 'Pakia uthibitisho wa malipo';

  @override
  String get paymentDepositInstructions => 'Maelekezo ya amana';

  @override
  String get paymentWalletAddress => 'Anwani ya pochi';

  @override
  String get paymentTransactionHash => 'Hashi ya muamala';

  @override
  String get paymentHashHint => 'Bandika hashi ya muamala wa blockchain';

  @override
  String get paymentStepQuote => 'Bei';

  @override
  String get paymentStepSend => 'Tuma';

  @override
  String get paymentStepReview => 'Kagua';

  @override
  String get paymentCopy => 'Nakili';

  @override
  String get paymentWalletCopied => 'Anwani ya pochi imenakiliwa';

  @override
  String get supportNewRequest => 'Ombi jipya la msaada';

  @override
  String get supportNoRequestsTitle => 'Bado hakuna maombi ya msaada';

  @override
  String get supportNoRequestsBody =>
      'Anzisha mazungumzo na timu ya BrickClub unapohitaji msaada wa akaunti, KYC, pochi, au uwekezaji.';

  @override
  String get supportSendRequest => 'Tuma ombi';

  @override
  String get supportReplyTitle => 'Jibu kwa msaada';

  @override
  String get supportSendReply => 'Tuma jibu';

  @override
  String supportMessagesCount(int count) {
    return 'Ujumbe $count';
  }

  @override
  String get supportRequestClosed => 'Ombi limefungwa';

  @override
  String get supportReply => 'Jibu';

  @override
  String get supportTalkDirectly => 'Zungumza nasi moja kwa moja';

  @override
  String get supportTalkBody =>
      'Unapendelea gumzo la haraka? Wasiliana na timu ya msaada ya BrickClub kupitia WhatsApp au Telegram kwa msaada wa haraka.';

  @override
  String get supportNoMessagesYet => 'Bado hakuna ujumbe';

  @override
  String get supportTeamName => 'Msaada wa BrickClub';

  @override
  String get supportYou => 'Wewe';

  @override
  String get supportSubject => 'Mada';

  @override
  String get supportSubjectHint => 'Unahitaji msaada wa nini?';

  @override
  String get supportMessage => 'Ujumbe';

  @override
  String get supportMessageHint => 'Andika ujumbe wako';

  @override
  String get supportEnterSubject => 'Weka mada';

  @override
  String get supportEnterMessage => 'Weka ujumbe';

  @override
  String get supportMessageSent => 'Ujumbe umetumwa';

  @override
  String supportCouldNotOpen(String url) {
    return 'Imeshindwa kufungua $url';
  }

  @override
  String get navHome => 'Mwanzo';

  @override
  String get navMore => 'Zaidi';

  @override
  String get notificationsNone => 'Hakuna arifa mpya';

  @override
  String get profileInMore => 'Wasifu uko kwenye Zaidi';

  @override
  String get investmentCardCryptoFunding => 'Ufadhili wa sarafu-fiche';

  @override
  String get commonShowPassword => 'Onyesha nenosiri';

  @override
  String get commonHidePassword => 'Ficha nenosiri';

  @override
  String get errAuthEmulatorUnreachable =>
      'Programu haikuweza kufikia emuleta ya Firebase Auth. Jenga upya programu ya utatuzi na uhakikishe emuleta za Firebase zinaendelea.';

  @override
  String get errInvalidEmail => 'Weka anwani halali ya barua pepe.';

  @override
  String get errMissingEmail => 'Weka anwani yako ya barua pepe.';

  @override
  String get errMissingPassword => 'Weka nenosiri lako.';

  @override
  String get errUserNotFound => 'Hakuna akaunti ya barua pepe hiyo.';

  @override
  String get errWrongPassword => 'Barua pepe au nenosiri si sahihi.';

  @override
  String get errEmailInUse => 'Tayari kuna akaunti ya barua pepe hiyo.';

  @override
  String get errWeakPassword =>
      'Tumia nenosiri imara zaidi lenye angalau herufi 6.';

  @override
  String get errOperationNotAllowed =>
      'Kuingia kwa barua pepe bado hakujawezeshwa. Wasiliana na usaidizi.';

  @override
  String get errUserDisabled =>
      'Akaunti hii imezimwa. Wasiliana na usaidizi kwa msaada.';

  @override
  String get errTooManyRequests =>
      'Majaribio mengi mno. Subiri kidogo kabla ya kujaribu tena.';

  @override
  String get errNetworkFailed =>
      'Hatukuweza kuunganisha. Angalia mtandao wako na ujaribu tena.';

  @override
  String get errRequiresRecentLogin =>
      'Ingia tena kabla ya kufanya mabadiliko haya.';

  @override
  String get errExpiredActionCode =>
      'Kiungo hiki kimeisha muda. Omba kipya na ujaribu tena.';

  @override
  String get errInvalidActionCode =>
      'Kiungo hiki hakitumiki tena. Omba kipya na ujaribu tena.';

  @override
  String get errAccountRequestFailed =>
      'Hatukuweza kukamilisha ombi hilo la akaunti. Tafadhali jaribu tena.';

  @override
  String get errResetUnavailable =>
      'Barua pepe ya kuweka upya nenosiri haipatikani kwa muda. Tafadhali jaribu tena hivi karibuni.';

  @override
  String get errResetNotAvailable =>
      'Kuweka upya nenosiri hakupatikani kwa sasa.';

  @override
  String get errResetFailed =>
      'Hatukuweza kutuma barua pepe ya kuweka upya. Tafadhali jaribu tena.';

  @override
  String get errSignInAgain => 'Ingia tena ili kuendelea.';

  @override
  String get errAdminNoPermission =>
      'Akaunti yako haina ruhusa ya kufanya hivyo.';

  @override
  String get errEmailEnvUnavailable =>
      'Kutuma barua pepe hakupatikani katika mazingira haya.';

  @override
  String get errAddEmailFirst =>
      'Ongeza anwani ya barua pepe kwenye akaunti yako kwanza.';

  @override
  String get errPermissionDenied => 'Huna ruhusa ya kufanya hivyo.';

  @override
  String get errGeneric => 'Hitilafu imetokea. Tafadhali jaribu tena.';

  @override
  String get errKycInvalidCode => 'Weka msimbo wa SMS kutoka kwa emuleta.';

  @override
  String get errKycCredentialInUse =>
      'Nambari hiyo ya simu tayari imeunganishwa na akaunti nyingine.';

  @override
  String get errKycTooManyRequests =>
      'Majaribio mengi mno ya uthibitisho. Jaribu baadaye.';

  @override
  String get errKycPhoneFailed =>
      'Uthibitisho wa simu umeshindwa. Tafadhali jaribu tena.';

  @override
  String get errKycSignInAgain => 'Ingia tena ili kuendelea na KYC.';

  @override
  String get errKycNoPermission =>
      'Huna ruhusa ya kusasisha wasifu huu wa KYC.';

  @override
  String get errKycUnavailable =>
      'Huduma za KYC hazipatikani kwa muda. Tafadhali jaribu tena hivi karibuni.';

  @override
  String get errKycDeadline =>
      'Ombi limechukua muda mrefu mno. Tafadhali angalia muunganisho wako na ujaribu tena.';

  @override
  String get errKycStorageUnauthorized => 'Huna ruhusa ya kupakia hati hii.';

  @override
  String get errKycStorageCanceled => 'Upakiaji wa hati umeghairiwa.';

  @override
  String get errKycStorageRetry =>
      'Upakiaji umechukua muda mrefu mno. Tafadhali angalia muunganisho wako na ujaribu tena.';

  @override
  String get errKycStorageQuota =>
      'Upakiaji wa hati haupatikani kwa muda. Tafadhali jaribu tena baadaye.';

  @override
  String get filterAll => 'Zote';

  @override
  String get enumAssetRealEstate => 'Mali isiyohamishika';

  @override
  String get enumAssetReit => 'REIT';

  @override
  String get enumAssetEtf => 'ETF';

  @override
  String get enumAssetIndex => 'Mfuko wa fahirisi';

  @override
  String get enumAssetAlternative => 'Mbadala';

  @override
  String get enumRiskConservative => 'Mwangalifu';

  @override
  String get enumRiskBalanced => 'Uwiano';

  @override
  String get enumRiskGrowth => 'Ukuaji';
}
