// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'Lingua';

  @override
  String get languageScreenTitle => 'Lingua';

  @override
  String get languageHeading => 'Lingua di visualizzazione';

  @override
  String get languageDescription =>
      'Scegli la lingua che BrickClub usa su questo dispositivo.';

  @override
  String get languageSystemDefault => 'Predefinito di sistema';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonEmailHint => 'tu@esempio.com';

  @override
  String get commonPassword => 'Password';

  @override
  String get authConnecting => 'Connessione…';

  @override
  String get signInWelcomeTitle => 'Bentornato';

  @override
  String get signInAdminTitle => 'Accesso amministratore';

  @override
  String get signInMemberSubtitle =>
      'Continua verso il tuo portafoglio BrickShares.';

  @override
  String get signInAdminSubtitle =>
      'Accedi alle operazioni su utenti, asset e pagamenti in cripto.';

  @override
  String get signInPasswordHint => 'Inserisci la tua password';

  @override
  String get signInForgotPassword => 'Password dimenticata?';

  @override
  String get signInProgress => 'Accesso in corso…';

  @override
  String get signInOpenAdminDashboard => 'Apri la dashboard amministratore';

  @override
  String get signInSubmit => 'Accedi in modo sicuro';

  @override
  String get signInGoogleAdmin => 'Continua come amministratore con Google';

  @override
  String get signInGoogle => 'Continua con Google';

  @override
  String get signInPhone => 'Continua con il telefono';

  @override
  String get signInUseMember => 'Usa l\'accesso membro';

  @override
  String get signInUseAdmin => 'Accedi come amministratore';

  @override
  String get signInCreateAccount => 'Crea un account BrickClub';

  @override
  String get signInGoogleNoAdmin =>
      'Questo account Google non dispone dell\'accesso amministratore.';

  @override
  String get signInNoAdmin =>
      'Questo account non dispone dell\'accesso amministratore.';

  @override
  String get signInResetSent =>
      'Istruzioni per la reimpostazione della password inviate';

  @override
  String get signInStoryTitle => 'La proprietà, resa\npiù accessibile.';

  @override
  String get signInStoryBody =>
      'Esamina opportunità verificate, regola con sicurezza e tieni d\'occhio ogni asset.';

  @override
  String get signUpIntro =>
      'Crea il tuo account BrickShares. La verifica del portafoglio e il KYC arrivano subito dopo.';

  @override
  String get signUpCreateAccount => 'Crea account';

  @override
  String get signUpLegalNamesHint =>
      'Usa i tuoi nomi legali esattamente come compaiono sul documento d\'identità.';

  @override
  String get signUpFirstName => 'Nome';

  @override
  String get signUpFirstNameHint => 'Nome legale';

  @override
  String get signUpLastName => 'Cognome';

  @override
  String get signUpLastNameHint => 'Cognome legale';

  @override
  String get signUpPasswordHint => 'Crea una password';

  @override
  String get signUpConfirmPassword => 'Conferma password';

  @override
  String get signUpConfirmPasswordHint => 'Conferma la tua password';

  @override
  String get signUpAgree =>
      'Accetto i termini, le informative sui rischi e le notifiche di conferma del regolamento.';

  @override
  String get signUpProgress => 'Creazione account…';

  @override
  String get signUpGoogle => 'Registrati con Google';

  @override
  String get signUpDisclosure =>
      'Le azioni finanziarie richiedono il KYC e la configurazione di un portafoglio verificato dopo la creazione dell\'account.';

  @override
  String get signUpHaveAccount => 'Hai già un account? Accedi';

  @override
  String get phoneTitle => 'Accedi con il telefono';

  @override
  String get phoneOtpTitle => 'Inserisci il codice di verifica';

  @override
  String get phoneSubtitle =>
      'Inserisci il tuo numero di telefono con il prefisso internazionale (es. +1 415 555 2671).';

  @override
  String phoneOtpSubtitle(String phone) {
    return 'Abbiamo inviato un codice di 6 cifre a $phone.';
  }

  @override
  String get phoneHint => '+1 415 555 2671';

  @override
  String get phoneCodeHint => '000000';

  @override
  String get phoneSendingCode => 'Invio del codice…';

  @override
  String get phoneSendCode => 'Invia codice di verifica';

  @override
  String get phoneVerifying => 'Verifica…';

  @override
  String get phoneConfirmCode => 'Conferma codice';

  @override
  String get phoneUseDifferentNumber => 'Usa un altro numero';

  @override
  String get installIosTitle => 'Installa su iPhone o iPad';

  @override
  String get installIosIntro =>
      'Aggiungi BrickClub alla schermata Home direttamente da Safari, senza App Store.';

  @override
  String get installIosStep1 =>
      'Tocca il pulsante Condividi nella barra degli strumenti di Safari.';

  @override
  String get installIosStep2 =>
      'Scorri verso il basso e scegli «Aggiungi a Home».';

  @override
  String get installIosStep3 =>
      'Tocca «Aggiungi»: BrickClub comparirà nella schermata Home.';

  @override
  String get installAndroidTitle => 'Installa su Android';

  @override
  String get installAndroidIntro =>
      'Aggiungi BrickClub al tuo dispositivo con un paio di tocchi dal browser.';

  @override
  String get installAndroidStep1 =>
      'Apri il menu del browser (⋮ nell\'angolo in alto).';

  @override
  String get installAndroidStep2 =>
      'Tocca «Installa app» o «Aggiungi a schermata Home».';

  @override
  String get installAndroidStep3 =>
      'Conferma: BrickClub comparirà nel cassetto delle app.';

  @override
  String get installDesktopTitle => 'Installa su desktop';

  @override
  String get installDesktopIntro =>
      'Installa BrickClub come app da Chrome o Edge.';

  @override
  String get installDesktopStep1 =>
      'Fai clic sull\'icona di installazione nella barra degli indirizzi o apri il menu del browser.';

  @override
  String get installDesktopStep2 =>
      'Scegli «Installa» per avviare BrickClub in una finestra dedicata.';

  @override
  String get installGotIt => 'Ho capito';

  @override
  String get installAlready =>
      'BrickClub è già installato su questo dispositivo.';

  @override
  String get installInstalling =>
      'Installazione di BrickClub sul tuo dispositivo…';

  @override
  String get installDismissed =>
      'Installazione annullata. Puoi installarlo in qualsiasi momento.';

  @override
  String get navFeatures => 'Funzionalità';

  @override
  String get navHowItWorks => 'Come funziona';

  @override
  String get navTestimonials => 'Testimonianze';

  @override
  String get landingSignIn => 'Accedi';

  @override
  String get landingSignUp => 'Registrati';

  @override
  String get landingJoin => 'Unisciti';

  @override
  String get landingCreateAccount => 'Crea account';

  @override
  String get heroTitle => 'Possiedi più di\nun sogno.';

  @override
  String get heroBody =>
      'Costruisci una proprietà reale attraverso BrickShares verificate e garantite da immobili, con prestazioni trasparenti e un regolamento cripto affidabile da un\'unica app sicura.';

  @override
  String get heroInstall => 'Installa l\'app';

  @override
  String get heroExplore => 'Esplora BrickShares';

  @override
  String get proofVerifiedAssets => 'Asset verificati';

  @override
  String get proofTrustedSettlement => 'Regolamento affidabile';

  @override
  String get proofClearPerformance => 'Prestazioni chiare';

  @override
  String get previewPortfolioValue => 'Valore del portafoglio';

  @override
  String get previewMinimum => 'Minimo';

  @override
  String get previewTargetReturn => 'Rendimento obiettivo';

  @override
  String get heroCardTargetReturn => 'Rendimento annuo obiettivo';

  @override
  String get assetVerifiedBadge => 'ASSET VERIFICATO';

  @override
  String get assetSampleDescription =>
      'Immobile residenziale che genera reddito';

  @override
  String get assetFunded => 'Finanziato';

  @override
  String get trustDueDiligence => 'DUE DILIGENCE IMMOBILIARE';

  @override
  String get trustKycVerified => 'MEMBRI VERIFICATI KYC';

  @override
  String get trustUsdtSettlement => 'REGOLAMENTO IN USDT';

  @override
  String get trustOwnershipRecords => 'REGISTRI DI PROPRIETÀ CHIARI';

  @override
  String get statTargetReturn => 'Rendimento obiettivo medio';

  @override
  String get statMinimum => 'Minimo per iniziare';

  @override
  String get statSettlement => 'Regolamento on-chain';

  @override
  String get statVisibility => 'Visibilità del portafoglio';

  @override
  String get howTitle => 'Dalla registrazione alla proprietà.';

  @override
  String get howSubtitle =>
      'Un percorso chiaro pensato per gli investitori che vogliono fiducia a ogni passo.';

  @override
  String get howStep1Title => 'Crea e verifica';

  @override
  String get howStep1Body =>
      'Apri il tuo account, completa il KYC e collega un portafoglio verificato.';

  @override
  String get howStep2Title => 'Scegli BrickShares';

  @override
  String get howStep2Body =>
      'Esamina asset verificati, rendimenti obiettivo, rischi e termini di proprietà.';

  @override
  String get howStep3Title => 'Finanzia e monitora';

  @override
  String get howStep3Body =>
      'Regola in sicurezza con le cripto supportate e monitora il tuo portafoglio.';

  @override
  String get featuresTitle => 'Creato per la chiarezza,\nnon la speculazione.';

  @override
  String get featuresBody =>
      'Ogni opportunità mette in primo piano le informazioni importanti: struttura della proprietà, verifica dell\'asset, rendimenti obiettivo, rischi, rete di finanziamento e stato del regolamento.';

  @override
  String get feature1 => 'Documentazione degli asset verificata';

  @override
  String get feature2 => 'Quotazioni cripto e commissioni di rete trasparenti';

  @override
  String get feature3 => 'Conferma prima di ogni azione finanziaria';

  @override
  String get testimonialsTitle => 'Costruito sulla fiducia degli investitori.';

  @override
  String get testimonialsSubtitle =>
      'Ciò che i primi membri di BrickClub apprezzano di più dell\'esperienza.';

  @override
  String get testimonial1Quote =>
      'BrickClub rende facili da capire i dettagli importanti. So cosa possiedo, come sta rendendo e cosa succede prima di finanziare.';

  @override
  String get testimonial1Role => 'Imprenditrice, Londra';

  @override
  String get testimonial2Quote =>
      'Il flusso di verifica e conferma mi ha dato fiducia. Sembra una piattaforma di investimento seria, non l\'ennesima scorciatoia cripto.';

  @override
  String get testimonial2Role => 'Responsabile di prodotto, Singapore';

  @override
  String get testimonial3Quote =>
      'Posso iniziare con un importo pratico e avere comunque accesso ad asset che normalmente osserverei solo dall\'esterno.';

  @override
  String get testimonial3Role => 'Consulente, Dubai';

  @override
  String get ctaBadge => 'INIZIA IN POCHI MINUTI';

  @override
  String get ctaTitle => 'Il tuo prossimo asset può iniziare qui.';

  @override
  String get ctaBody =>
      'Installa BrickClub, crea il tuo account ed esplora BrickShares verificate pensate per la proprietà a lungo termine.';

  @override
  String get ctaHaveAccount => 'Ho già un account';

  @override
  String get ctaSecureKyc => 'KYC sicuro';

  @override
  String get ctaFreeToBrowse => 'Naviga gratis';

  @override
  String get ctaVerifiedOnly => 'Solo asset verificati';

  @override
  String get footerCopyright => '© 2026 BrickClub';

  @override
  String get commonViewAll => 'Vedi tutto';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get navInvest => 'Investi';

  @override
  String get navWallet => 'Portafoglio';

  @override
  String get navPortfolio => 'Portfolio';

  @override
  String get navProfile => 'Profilo';

  @override
  String get kycGateTitle => 'Completa prima il KYC';

  @override
  String kycGateBody(String status) {
    return 'Stato: $status. Acquisti, prelievi, modifiche al portafoglio e regolamento cripto si sbloccano dopo l\'approvazione.';
  }

  @override
  String get kycGateViewStatus => 'Visualizza stato KYC';

  @override
  String get kycGateComplete => 'Completa il KYC';

  @override
  String get homeFeaturedOpportunity => 'Opportunità in evidenza';

  @override
  String get homeNoLiveTitle => 'Ancora nessuna BrickShare attiva';

  @override
  String get homeNoLiveBody =>
      'Gli asset pubblicati e verificati compariranno qui.';

  @override
  String get homeViewInvest => 'Vai a Investi';

  @override
  String get homeYourHoldings => 'Le tue posizioni';

  @override
  String get homeRecentActivity => 'Attività recente';

  @override
  String get holdingsEmptyTitle => 'Ancora nessuna posizione';

  @override
  String get holdingsEmptyHome =>
      'I depositi verificati compariranno qui come BrickShares.';

  @override
  String get activityEmptyTitle => 'Ancora nessuna attività';

  @override
  String get activityEmptyBody =>
      'Le richieste di deposito e gli aggiornamenti di regolamento compariranno qui.';

  @override
  String get dashboardErrorTitle => 'Impossibile caricare i dati dell\'account';

  @override
  String get dashboardErrorBody =>
      'Controlla la connessione al backend e riprova.';

  @override
  String get investSubtitle => 'Esplora BrickShares multi-asset verificate';

  @override
  String get investSearchHint => 'Cerca per nome, posizione o classe di asset';

  @override
  String investAvailable(int count) {
    return 'Disponibili $count';
  }

  @override
  String get investFilteredIncome => 'BrickShares a reddito\nfiltrate';

  @override
  String investOpportunitiesCount(int count) {
    return '$count opportunità';
  }

  @override
  String get investLoadingOpportunities => 'Caricamento opportunità';

  @override
  String get investFiltersAction => 'Filtri';

  @override
  String get investNoMatchTitle => 'Nessuna BrickShare corrispondente';

  @override
  String get investNoMatchEmpty =>
      'Gli asset verificati pubblicati dall\'amministratore compariranno qui.';

  @override
  String investNoMatchSearch(String query) {
    return 'Nessuna BrickShare corrisponde a «$query». Prova un\'altra ricerca o modifica i filtri.';
  }

  @override
  String get investNoMatchFilters =>
      'Prova un\'altra classe di asset, livello di rischio o metodo di pagamento.';

  @override
  String get investResetFilters => 'Reimposta filtri';

  @override
  String get walletCryptoActivity => 'Attività degli ordini cripto';

  @override
  String get walletFundingTitle => 'Pronto per il finanziamento cripto';

  @override
  String get walletFundingBody =>
      'Aggiungi un portafoglio verificato prima di inviare fondi. Rete, commissioni, scadenza della quotazione e stato del regolamento sono mostrati prima della conferma.';

  @override
  String get walletAddWallet => 'Aggiungi portafoglio verificato';

  @override
  String get walletVerificationStarted => 'Verifica del portafoglio avviata';

  @override
  String get walletSettlementTitle => 'Conferma di regolamento richiesta';

  @override
  String get walletSettlementBody =>
      'Acquisti, prelievi e modifiche al portafoglio richiedono la conferma finale.';

  @override
  String get walletVerifiedBalance => 'Saldo del portafoglio verificato';

  @override
  String get portfolioCurrentValue => 'Valore attuale del portfolio';

  @override
  String get portfolioInvested => 'Investito';

  @override
  String get portfolioProfitLoss => 'Profitto / perdita';

  @override
  String get portfolioReturn => 'Rendimento';

  @override
  String portfolioDividends(String amount) {
    return 'Dividendi ricevuti: $amount';
  }

  @override
  String get portfolioHoldings => 'Posizioni';

  @override
  String get portfolioHoldingsEmptyBody =>
      'Gli investimenti approvati compaiono qui automaticamente.';

  @override
  String get portfolioAllocation => 'Allocazione';

  @override
  String get portfolioAllocationEmptyTitle => 'Ancora nessuna allocazione';

  @override
  String get portfolioAllocationEmptyBody =>
      'Il tuo mix di asset compare dopo la verifica dei depositi.';

  @override
  String portfolioInvestedOwnership(String invested, String ownership) {
    return 'Investito $invested · $ownership di proprietà';
  }

  @override
  String get profileSettings => 'Impostazioni';

  @override
  String profileThemeSubtitle(String mode) {
    return 'Tema $mode';
  }

  @override
  String get profileSecurityTitle => 'Sicurezza e privacy';

  @override
  String get profileSecuritySubtitle => 'Portafoglio verificato e biometria';

  @override
  String get profileDocumentsTitle => 'Documenti';

  @override
  String get profileDocumentsSubtitle =>
      'Estratti conto, informative sui rischi';

  @override
  String profileRowOpened(String title) {
    return '$title aperto';
  }

  @override
  String get profileSupport => 'Assistenza';

  @override
  String get profileSupportSubtitle => 'Scrivi al team di BrickClub';

  @override
  String get profileLogout => 'Esci';

  @override
  String get profileLogoutConfirmTitle => 'Uscire?';

  @override
  String get profileLogoutConfirmBody =>
      'Dovrai accedere di nuovo per accedere al tuo account.';

  @override
  String get profileDefaultName => 'Membro BrickClub';

  @override
  String get profileDefaultSubtitle =>
      'I dati del tuo account e delle tue BrickShares';

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
  String get themeScreenTitle => 'Tema';

  @override
  String get themeAppearance => 'Aspetto';

  @override
  String get themeAppearanceDescription =>
      'Scegli come appare BrickClub su questo dispositivo.';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystemDescription =>
      'Segui automaticamente questo dispositivo.';

  @override
  String get themeLightDescription =>
      'Usa un\'interfaccia chiara con testo scuro.';

  @override
  String get themeDarkDescription =>
      'Usa la classica interfaccia scura di BrickClub.';

  @override
  String get commonSending => 'Invio…';

  @override
  String get commonSubmitting => 'Invio…';

  @override
  String get filtersAssetClass => 'Classe di asset';

  @override
  String get filtersRiskLevel => 'Livello di rischio';

  @override
  String get filtersPaymentMethod => 'Metodo di pagamento';

  @override
  String get filtersReset => 'Reimposta';

  @override
  String filtersShow(int count) {
    return 'Mostra $count';
  }

  @override
  String get successTitle => 'Prova inviata';

  @override
  String get successBody =>
      'La tua prova di pagamento è in attesa di verifica da parte dell\'amministratore. Ti avviseremo dopo la revisione.';

  @override
  String get successSettlementStatus => 'Stato del regolamento';

  @override
  String get successViewPortfolio => 'Vedi portfolio';

  @override
  String get detailVerifiedDocs => 'Documenti verificati';

  @override
  String detailAssetLine(String assetClass, String location) {
    return '$assetClass BrickShares | $location';
  }

  @override
  String get detailLiquidity => 'Liquidità';

  @override
  String get detailFundingStatus => 'Stato del finanziamento';

  @override
  String detailFundedPercent(String percent) {
    return '$percent% finanziato';
  }

  @override
  String get detailFundingNote =>
      'Le opzioni di pagamento supportate e la scadenza della quotazione sono mostrate prima della conferma del regolamento.';

  @override
  String get detailInvestButton => 'Investi con finanziamento cripto';

  @override
  String get kycStatusApproved => 'Le azioni finanziarie sono sbloccate.';

  @override
  String get kycStatusSubmitted => 'I tuoi documenti sono in revisione.';

  @override
  String get kycStatusRejectedDefault =>
      'Controlla la richiesta e invia di nuovo.';

  @override
  String get kycStatusDefault =>
      'Richiesto prima di acquisti e modifiche al portafoglio.';

  @override
  String get kycChipPhone => 'Telefono';

  @override
  String get kycChipIdentity => 'Identità';

  @override
  String get kycChipOk => 'OK';

  @override
  String get kycChipNeeded => 'Da fare';

  @override
  String get kycViewDetails => 'Vedi dettagli KYC';

  @override
  String get kycVerifyIdentity => 'Verifica identità';

  @override
  String get kycFullName => 'Nome legale completo';

  @override
  String get kycFullNameHint =>
      'Nome esattamente come appare sul tuo documento';

  @override
  String get kycDob => 'Data di nascita';

  @override
  String get kycSelectDate => 'Seleziona data';

  @override
  String get kycGovId => 'Documento d\'identità o passaporto';

  @override
  String get kycUploadId => 'Carica documento d\'identità';

  @override
  String get kycSelfie => 'Selfie / verifica del volto';

  @override
  String get kycCaptureSelfie => 'Scatta un selfie';

  @override
  String get kycAddressProof => 'Prova di indirizzo fisico';

  @override
  String get kycUploadAddress => 'Carica bolletta o contratto di affitto';

  @override
  String get kycPhoneVerification => 'Verifica del telefono';

  @override
  String get kycSendCode => 'Invia codice';

  @override
  String get kycVerificationCodeHint => 'Codice di verifica';

  @override
  String get kycEmailVerification => 'Verifica dell\'email';

  @override
  String get kycEmailVerified => 'Email verificata';

  @override
  String get kycEmailNotVerified => 'Email non verificata';

  @override
  String get kycSendEmail => 'Invia email';

  @override
  String get kycSubmitForReview => 'Invia per la revisione';

  @override
  String get kycEmulatorNote =>
      'I codici telefonici appaiono nell\'emulatore Firebase Auth. Le email di sviluppo appaiono in Mailpit.';

  @override
  String get kycEmailSent => 'Email di verifica inviata';

  @override
  String get kycEnterPhoneFirst => 'Inserisci prima il tuo numero di telefono';

  @override
  String get kycCodeSent =>
      'Codice inviato. Controlla l\'emulatore Firebase Auth.';

  @override
  String get kycSubmitted => 'KYC inviato per i controlli automatici';

  @override
  String get kycMissingName => 'Inserisci il tuo nome legale';

  @override
  String get kycMissingDob => 'Seleziona la tua data di nascita';

  @override
  String get kycMissingId => 'Carica il tuo documento d\'identità o passaporto';

  @override
  String get kycMissingSelfie => 'Scatta un selfie';

  @override
  String get kycMissingAddress => 'Carica una prova di indirizzo';

  @override
  String get kycMissingPhone => 'Inserisci il tuo numero di telefono';

  @override
  String get kycInvalidPhone =>
      'Inserisci il tuo numero di telefono in formato internazionale, es. +12025550190.';

  @override
  String get kycMissingCode => 'Inserisci il codice di verifica del telefono';

  @override
  String get kycUpdateFailed =>
      'Non siamo riusciti ad aggiornare i tuoi dati KYC. Riprova.';

  @override
  String get paymentConfirmFunding => 'Conferma finanziamento';

  @override
  String get paymentSetup => 'Configurazione finanziamento cripto';

  @override
  String get paymentStatusDraft => 'Bozza';

  @override
  String get paymentStatusActive => 'Attivo';

  @override
  String get paymentRail => 'Canale di pagamento';

  @override
  String get paymentAmount => 'Importo dell\'investimento';

  @override
  String get paymentAmountHint => 'Importo in USD';

  @override
  String paymentBelowMinimum(String minimum) {
    return 'Il minimo per questa opportunità è $minimum.';
  }

  @override
  String get paymentDemoAmount =>
      'L\'importo demo può essere modificato prima di creare la richiesta di deposito.';

  @override
  String get paymentQuotePaymentAsset => 'Asset di pagamento';

  @override
  String get paymentQuoteAmount => 'Importo';

  @override
  String get paymentQuoteNetwork => 'Rete';

  @override
  String get paymentNetworkAfterRequest => 'Selezionata dopo la richiesta';

  @override
  String get paymentQuote => 'Quotazione';

  @override
  String get paymentQuoteByBackend => 'Creata dal backend';

  @override
  String get paymentNetworkFee => 'Commissione di rete';

  @override
  String get paymentFeeByBackend => 'Calcolata dal backend';

  @override
  String get paymentSettlement => 'Regolamento';

  @override
  String get paymentPendingConfirmation => 'In attesa di conferma';

  @override
  String get paymentConfirmableTitle => 'Azione finanziaria confermabile';

  @override
  String get paymentConfirmableBody =>
      'Stai autorizzando un acquisto di BrickShares finanziato in cripto. Il regolamento può richiedere conferme di rete.';

  @override
  String get paymentCreateRequest => 'Crea richiesta di deposito';

  @override
  String get paymentSubmitProof => 'Invia prova per la revisione';

  @override
  String get paymentIncreaseAmount =>
      'Aumenta l\'importo fino al minimo dell\'opportunità.';

  @override
  String get paymentDepositCreated => 'Richiesta di deposito creata';

  @override
  String get paymentEnterHash => 'Inserisci l\'hash della transazione';

  @override
  String get paymentUploadProof => 'Carica la prova di pagamento';

  @override
  String get paymentDepositInstructions => 'Istruzioni per il deposito';

  @override
  String get paymentWalletAddress => 'Indirizzo del portafoglio';

  @override
  String get paymentTransactionHash => 'Hash della transazione';

  @override
  String get paymentHashHint => 'Incolla l\'hash della transazione blockchain';

  @override
  String get paymentStepQuote => 'Quotazione';

  @override
  String get paymentStepSend => 'Invia';

  @override
  String get paymentStepReview => 'Revisione';

  @override
  String get paymentCopy => 'Copia';

  @override
  String get paymentWalletCopied => 'Indirizzo del portafoglio copiato';

  @override
  String get supportNewRequest => 'Nuova richiesta di assistenza';

  @override
  String get supportNoRequestsTitle => 'Ancora nessuna richiesta di assistenza';

  @override
  String get supportNoRequestsBody =>
      'Avvia una conversazione con il team di BrickClub quando hai bisogno di aiuto su account, KYC, portafoglio o investimenti.';

  @override
  String get supportSendRequest => 'Invia richiesta';

  @override
  String get supportReplyTitle => 'Rispondi all\'assistenza';

  @override
  String get supportSendReply => 'Invia risposta';

  @override
  String supportMessagesCount(int count) {
    return '$count messaggi';
  }

  @override
  String get supportRequestClosed => 'Richiesta chiusa';

  @override
  String get supportReply => 'Rispondi';

  @override
  String get supportTalkDirectly => 'Parla direttamente con noi';

  @override
  String get supportTalkBody =>
      'Preferisci una chat veloce? Contatta il team di assistenza BrickClub su WhatsApp o Telegram per un aiuto più rapido.';

  @override
  String get supportNoMessagesYet => 'Ancora nessun messaggio';

  @override
  String get supportTeamName => 'Assistenza BrickClub';

  @override
  String get supportYou => 'Tu';

  @override
  String get supportSubject => 'Oggetto';

  @override
  String get supportSubjectHint => 'Di cosa hai bisogno?';

  @override
  String get supportMessage => 'Messaggio';

  @override
  String get supportMessageHint => 'Scrivi il tuo messaggio';

  @override
  String get supportEnterSubject => 'Inserisci un oggetto';

  @override
  String get supportEnterMessage => 'Inserisci un messaggio';

  @override
  String get supportMessageSent => 'Messaggio inviato';

  @override
  String supportCouldNotOpen(String url) {
    return 'Impossibile aprire $url';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navMore => 'Altro';

  @override
  String get notificationsNone => 'Nessuna nuova notifica';

  @override
  String get profileInMore => 'Il profilo è in Altro';

  @override
  String get investmentCardCryptoFunding => 'Finanziamento cripto';

  @override
  String get commonShowPassword => 'Mostra password';

  @override
  String get commonHidePassword => 'Nascondi password';

  @override
  String get errAuthEmulatorUnreachable =>
      'L\'app non è riuscita a raggiungere l\'emulatore Firebase Auth. Ricompila l\'app di debug e assicurati che gli emulatori Firebase siano in esecuzione.';

  @override
  String get errInvalidEmail => 'Inserisci un indirizzo email valido.';

  @override
  String get errMissingEmail => 'Inserisci il tuo indirizzo email.';

  @override
  String get errMissingPassword => 'Inserisci la tua password.';

  @override
  String get errUserNotFound => 'Non esiste alcun account per quell\'email.';

  @override
  String get errWrongPassword => 'Email o password non corretti.';

  @override
  String get errEmailInUse => 'Esiste già un account per quell\'email.';

  @override
  String get errWeakPassword =>
      'Usa una password più sicura di almeno 6 caratteri.';

  @override
  String get errOperationNotAllowed =>
      'L\'accesso via email non è ancora abilitato. Contatta l\'assistenza.';

  @override
  String get errUserDisabled =>
      'Questo account è stato disabilitato. Contatta l\'assistenza per aiuto.';

  @override
  String get errTooManyRequests =>
      'Troppi tentativi. Attendi un momento prima di riprovare.';

  @override
  String get errNetworkFailed =>
      'Impossibile connettersi. Controlla la connessione e riprova.';

  @override
  String get errRequiresRecentLogin =>
      'Accedi di nuovo prima di apportare questa modifica.';

  @override
  String get errExpiredActionCode =>
      'Questo link è scaduto. Richiedine uno nuovo e riprova.';

  @override
  String get errInvalidActionCode =>
      'Questo link non è più valido. Richiedine uno nuovo e riprova.';

  @override
  String get errAccountRequestFailed =>
      'Non siamo riusciti a completare la richiesta dell\'account. Riprova.';

  @override
  String get errResetUnavailable =>
      'L\'email di reimpostazione della password è temporaneamente non disponibile. Riprova a breve.';

  @override
  String get errResetNotAvailable =>
      'La reimpostazione della password non è disponibile al momento.';

  @override
  String get errResetFailed =>
      'Non siamo riusciti a inviare l\'email di reimpostazione. Riprova.';

  @override
  String get errSignInAgain => 'Accedi di nuovo per continuare.';

  @override
  String get errAdminNoPermission =>
      'Il tuo account non ha l\'autorizzazione per farlo.';

  @override
  String get errEmailEnvUnavailable =>
      'L\'invio di email non è disponibile in questo ambiente.';

  @override
  String get errAddEmailFirst =>
      'Aggiungi prima un indirizzo email al tuo account.';

  @override
  String get errPermissionDenied => 'Non hai l\'autorizzazione per farlo.';

  @override
  String get errGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get errKycInvalidCode => 'Inserisci il codice SMS dall\'emulatore.';

  @override
  String get errKycCredentialInUse =>
      'Quel numero di telefono è già collegato a un altro account.';

  @override
  String get errKycTooManyRequests =>
      'Troppi tentativi di verifica. Riprova più tardi.';

  @override
  String get errKycPhoneFailed =>
      'Verifica del telefono non riuscita. Riprova.';

  @override
  String get errKycSignInAgain => 'Accedi di nuovo per continuare con il KYC.';

  @override
  String get errKycNoPermission =>
      'Non hai l\'autorizzazione per aggiornare questo profilo KYC.';

  @override
  String get errKycUnavailable =>
      'I servizi KYC sono temporaneamente non disponibili. Riprova a breve.';

  @override
  String get errKycDeadline =>
      'La richiesta ha richiesto troppo tempo. Controlla la connessione e riprova.';

  @override
  String get errKycStorageUnauthorized =>
      'Non hai l\'autorizzazione per caricare questo documento.';

  @override
  String get errKycStorageCanceled =>
      'Il caricamento del documento è stato annullato.';

  @override
  String get errKycStorageRetry =>
      'Il caricamento ha richiesto troppo tempo. Controlla la connessione e riprova.';

  @override
  String get errKycStorageQuota =>
      'I caricamenti di documenti sono temporaneamente non disponibili. Riprova più tardi.';

  @override
  String get filterAll => 'Tutti';

  @override
  String get enumAssetRealEstate => 'Immobiliare';

  @override
  String get enumAssetReit => 'REIT';

  @override
  String get enumAssetEtf => 'ETF';

  @override
  String get enumAssetIndex => 'Fondo indicizzato';

  @override
  String get enumAssetAlternative => 'Alternativo';

  @override
  String get enumRiskConservative => 'Conservativo';

  @override
  String get enumRiskBalanced => 'Bilanciato';

  @override
  String get enumRiskGrowth => 'Crescita';
}
