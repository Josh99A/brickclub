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
}
