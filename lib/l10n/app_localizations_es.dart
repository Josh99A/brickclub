// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get languageScreenTitle => 'Idioma';

  @override
  String get languageHeading => 'Idioma de visualización';

  @override
  String get languageDescription =>
      'Elige el idioma que BrickClub usa en este dispositivo.';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get commonEmail => 'Correo electrónico';

  @override
  String get commonEmailHint => 'tu@ejemplo.com';

  @override
  String get commonPassword => 'Contraseña';

  @override
  String get authConnecting => 'Conectando…';

  @override
  String get signInWelcomeTitle => 'Bienvenido de nuevo';

  @override
  String get signInAdminTitle => 'Inicio de sesión de administrador';

  @override
  String get signInMemberSubtitle => 'Continúa con tu cartera de BrickShares.';

  @override
  String get signInAdminSubtitle =>
      'Accede a las operaciones de usuarios, activos y pagos con cripto.';

  @override
  String get signInPasswordHint => 'Introduce tu contraseña';

  @override
  String get signInForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get signInProgress => 'Iniciando sesión…';

  @override
  String get signInOpenAdminDashboard => 'Abrir panel de administración';

  @override
  String get signInSubmit => 'Iniciar sesión de forma segura';

  @override
  String get signInGoogleAdmin => 'Continuar como administrador con Google';

  @override
  String get signInGoogle => 'Continuar con Google';

  @override
  String get signInPhone => 'Continuar con el teléfono';

  @override
  String get signInUseMember => 'Usar inicio de sesión de miembro';

  @override
  String get signInUseAdmin => 'Iniciar sesión como administrador';

  @override
  String get signInCreateAccount => 'Crear una cuenta de BrickClub';

  @override
  String get signInGoogleNoAdmin =>
      'Esta cuenta de Google no tiene acceso de administrador.';

  @override
  String get signInNoAdmin => 'Esta cuenta no tiene acceso de administrador.';

  @override
  String get signInResetSent =>
      'Instrucciones de restablecimiento de contraseña enviadas';

  @override
  String get signInStoryTitle => 'La propiedad, ahora\nmás accesible.';

  @override
  String get signInStoryBody =>
      'Revisa oportunidades verificadas, liquida con confianza y mantén cada activo a la vista.';

  @override
  String get signUpIntro =>
      'Crea tu cuenta de BrickShares. La verificación de la cartera y el KYC vienen a continuación.';

  @override
  String get signUpCreateAccount => 'Crear cuenta';

  @override
  String get signUpLegalNamesHint =>
      'Usa tus nombres legales exactamente como aparecen en tu documento de identidad.';

  @override
  String get signUpFirstName => 'Nombre';

  @override
  String get signUpFirstNameHint => 'Nombre legal';

  @override
  String get signUpLastName => 'Apellido';

  @override
  String get signUpLastNameHint => 'Apellido legal';

  @override
  String get signUpPasswordHint => 'Crea una contraseña';

  @override
  String get signUpConfirmPassword => 'Confirmar contraseña';

  @override
  String get signUpConfirmPasswordHint => 'Confirma tu contraseña';

  @override
  String get signUpAgree =>
      'Acepto los términos, las divulgaciones de riesgo y los avisos de confirmación de liquidación.';

  @override
  String get signUpProgress => 'Creando cuenta…';

  @override
  String get signUpGoogle => 'Registrarse con Google';

  @override
  String get signUpDisclosure =>
      'Las acciones financieras requieren KYC y la configuración de una cartera verificada tras crear la cuenta.';

  @override
  String get signUpHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get phoneTitle => 'Iniciar sesión con el teléfono';

  @override
  String get phoneOtpTitle => 'Introduce el código de verificación';

  @override
  String get phoneSubtitle =>
      'Introduce tu número de teléfono con el código de país (p. ej. +1 415 555 2671).';

  @override
  String phoneOtpSubtitle(String phone) {
    return 'Enviamos un código de 6 dígitos a $phone.';
  }

  @override
  String get phoneHint => '+1 415 555 2671';

  @override
  String get phoneCodeHint => '000000';

  @override
  String get phoneSendingCode => 'Enviando código…';

  @override
  String get phoneSendCode => 'Enviar código de verificación';

  @override
  String get phoneVerifying => 'Verificando…';

  @override
  String get phoneConfirmCode => 'Confirmar código';

  @override
  String get phoneUseDifferentNumber => 'Usar otro número';

  @override
  String get installIosTitle => 'Instalar en iPhone o iPad';

  @override
  String get installIosIntro =>
      'Añade BrickClub a tu pantalla de inicio directamente desde Safari, sin App Store.';

  @override
  String get installIosStep1 =>
      'Toca el botón Compartir en la barra de herramientas de Safari.';

  @override
  String get installIosStep2 =>
      'Desplázate hacia abajo y elige «Añadir a pantalla de inicio».';

  @override
  String get installIosStep3 =>
      'Toca «Añadir»: BrickClub aparecerá en tu pantalla de inicio.';

  @override
  String get installAndroidTitle => 'Instalar en Android';

  @override
  String get installAndroidIntro =>
      'Añade BrickClub a tu dispositivo con un par de toques desde tu navegador.';

  @override
  String get installAndroidStep1 =>
      'Abre el menú del navegador (⋮ en la esquina superior).';

  @override
  String get installAndroidStep2 =>
      'Toca «Instalar app» o «Añadir a pantalla de inicio».';

  @override
  String get installAndroidStep3 =>
      'Confirma: BrickClub aparecerá en tu cajón de aplicaciones.';

  @override
  String get installDesktopTitle => 'Instalar en el escritorio';

  @override
  String get installDesktopIntro =>
      'Instala BrickClub como aplicación desde Chrome o Edge.';

  @override
  String get installDesktopStep1 =>
      'Haz clic en el icono de instalación en la barra de direcciones o abre el menú del navegador.';

  @override
  String get installDesktopStep2 =>
      'Elige «Instalar» para abrir BrickClub en su propia ventana.';

  @override
  String get installGotIt => 'Entendido';

  @override
  String get installAlready =>
      'BrickClub ya está instalado en este dispositivo.';

  @override
  String get installInstalling => 'Instalando BrickClub en tu dispositivo…';

  @override
  String get installDismissed =>
      'Instalación cancelada. Puedes instalarlo cuando quieras.';

  @override
  String get navFeatures => 'Funciones';

  @override
  String get navHowItWorks => 'Cómo funciona';

  @override
  String get navTestimonials => 'Testimonios';

  @override
  String get landingSignIn => 'Iniciar sesión';

  @override
  String get landingSignUp => 'Registrarse';

  @override
  String get landingJoin => 'Únete';

  @override
  String get landingCreateAccount => 'Crear cuenta';

  @override
  String get heroTitle => 'Posee más que\nun sueño.';

  @override
  String get heroBody =>
      'Construye una propiedad real a través de BrickShares verificadas y respaldadas por inmuebles, con un rendimiento transparente y una liquidación cripto confiable desde una sola app segura.';

  @override
  String get heroInstall => 'Instalar la app';

  @override
  String get heroExplore => 'Explorar BrickShares';

  @override
  String get proofVerifiedAssets => 'Activos verificados';

  @override
  String get proofTrustedSettlement => 'Liquidación confiable';

  @override
  String get proofClearPerformance => 'Rendimiento claro';

  @override
  String get previewPortfolioValue => 'Valor de la cartera';

  @override
  String get previewMinimum => 'Mínimo';

  @override
  String get previewTargetReturn => 'Rendimiento objetivo';

  @override
  String get heroCardTargetReturn => 'Rendimiento anual objetivo';

  @override
  String get assetVerifiedBadge => 'ACTIVO VERIFICADO';

  @override
  String get assetSampleDescription =>
      'Propiedad residencial generadora de ingresos';

  @override
  String get assetFunded => 'Financiado';

  @override
  String get trustDueDiligence => 'DEBIDA DILIGENCIA DE INMUEBLES';

  @override
  String get trustKycVerified => 'MIEMBROS VERIFICADOS POR KYC';

  @override
  String get trustUsdtSettlement => 'LIQUIDACIÓN EN USDT';

  @override
  String get trustOwnershipRecords => 'REGISTROS DE PROPIEDAD CLAROS';

  @override
  String get statTargetReturn => 'Rendimiento objetivo medio';

  @override
  String get statMinimum => 'Mínimo para empezar';

  @override
  String get statSettlement => 'Liquidación on-chain';

  @override
  String get statVisibility => 'Visibilidad de la cartera';

  @override
  String get howTitle => 'Del registro a la propiedad.';

  @override
  String get howSubtitle =>
      'Un camino claro diseñado para inversores que quieren confianza en cada paso.';

  @override
  String get howStep1Title => 'Crea y verifica';

  @override
  String get howStep1Body =>
      'Abre tu cuenta, completa el KYC y conecta una cartera verificada.';

  @override
  String get howStep2Title => 'Elige BrickShares';

  @override
  String get howStep2Body =>
      'Revisa activos verificados, rendimientos objetivo, riesgos y condiciones de propiedad.';

  @override
  String get howStep3Title => 'Financia y haz seguimiento';

  @override
  String get howStep3Body =>
      'Liquida de forma segura con las criptos admitidas y supervisa tu cartera.';

  @override
  String get featuresTitle => 'Hecho para la claridad,\nno la especulación.';

  @override
  String get featuresBody =>
      'Cada oportunidad pone por delante la información importante: estructura de propiedad, verificación del activo, rendimientos objetivo, riesgos, red de financiación y estado de la liquidación.';

  @override
  String get feature1 => 'Documentación de activos verificada';

  @override
  String get feature2 =>
      'Cotizaciones cripto y comisiones de red transparentes';

  @override
  String get feature3 => 'Confirmación antes de cada acción financiera';

  @override
  String get testimonialsTitle => 'Construido sobre la confianza del inversor.';

  @override
  String get testimonialsSubtitle =>
      'Lo que más valoran de la experiencia los primeros miembros de BrickClub.';

  @override
  String get testimonial1Quote =>
      'BrickClub hace que los detalles importantes sean fáciles de entender. Sé qué poseo, cómo rinde y qué ocurre antes de financiar.';

  @override
  String get testimonial1Role => 'Emprendedora, Londres';

  @override
  String get testimonial2Quote =>
      'El flujo de verificación y confirmación me dio confianza. Parece una plataforma de inversión seria, no otro atajo cripto.';

  @override
  String get testimonial2Role => 'Líder de producto, Singapur';

  @override
  String get testimonial3Quote =>
      'Puedo empezar con una cantidad práctica y aun así acceder a activos que normalmente solo observaría desde fuera.';

  @override
  String get testimonial3Role => 'Consultora, Dubái';

  @override
  String get ctaBadge => 'EMPIEZA EN MINUTOS';

  @override
  String get ctaTitle => 'Tu próximo activo puede empezar aquí.';

  @override
  String get ctaBody =>
      'Instala BrickClub, crea tu cuenta y explora BrickShares verificadas creadas para la propiedad a largo plazo.';

  @override
  String get ctaHaveAccount => 'Ya tengo una cuenta';

  @override
  String get ctaSecureKyc => 'KYC seguro';

  @override
  String get ctaFreeToBrowse => 'Explorar es gratis';

  @override
  String get ctaVerifiedOnly => 'Solo activos verificados';

  @override
  String get footerCopyright => '© 2026 BrickClub';

  @override
  String get commonViewAll => 'Ver todo';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get navInvest => 'Invertir';

  @override
  String get navWallet => 'Cartera';

  @override
  String get navPortfolio => 'Portafolio';

  @override
  String get navProfile => 'Perfil';

  @override
  String get kycGateTitle => 'Completa el KYC primero';

  @override
  String kycGateBody(String status) {
    return 'Estado: $status. Las compras, retiros, cambios de cartera y la liquidación cripto se desbloquean tras la aprobación.';
  }

  @override
  String get kycGateViewStatus => 'Ver estado del KYC';

  @override
  String get kycGateComplete => 'Completar KYC';

  @override
  String get homeFeaturedOpportunity => 'Oportunidad destacada';

  @override
  String get homeNoLiveTitle => 'Aún no hay BrickShares activas';

  @override
  String get homeNoLiveBody =>
      'Los activos publicados y verificados aparecerán aquí.';

  @override
  String get homeViewInvest => 'Ver invertir';

  @override
  String get homeYourHoldings => 'Tus posiciones';

  @override
  String get homeRecentActivity => 'Actividad reciente';

  @override
  String get holdingsEmptyTitle => 'Aún no hay posiciones';

  @override
  String get holdingsEmptyHome =>
      'Los depósitos verificados aparecerán aquí como BrickShares.';

  @override
  String get activityEmptyTitle => 'Aún no hay actividad';

  @override
  String get activityEmptyBody =>
      'Las solicitudes de depósito y las actualizaciones de liquidación aparecerán aquí.';

  @override
  String get dashboardErrorTitle =>
      'No se pudieron cargar los datos de la cuenta';

  @override
  String get dashboardErrorBody =>
      'Comprueba la conexión con el backend e inténtalo de nuevo.';

  @override
  String get investSubtitle => 'Explora BrickShares multiactivo verificadas';

  @override
  String get investSearchHint =>
      'Busca por nombre, ubicación o clase de activo';

  @override
  String investAvailable(int count) {
    return 'Disponibles $count';
  }

  @override
  String get investFilteredIncome => 'BrickShares de ingresos\nfiltradas';

  @override
  String investOpportunitiesCount(int count) {
    return '$count oportunidades';
  }

  @override
  String get investLoadingOpportunities => 'Cargando oportunidades';

  @override
  String get investFiltersAction => 'Filtros';

  @override
  String get investNoMatchTitle => 'No hay BrickShares que coincidan';

  @override
  String get investNoMatchEmpty =>
      'Los activos verificados publicados por el administrador aparecerán aquí.';

  @override
  String investNoMatchSearch(String query) {
    return 'Ninguna BrickShare coincide con «$query». Prueba otra búsqueda o ajusta los filtros.';
  }

  @override
  String get investNoMatchFilters =>
      'Prueba otra clase de activo, nivel de riesgo o método de pago.';

  @override
  String get investResetFilters => 'Restablecer filtros';

  @override
  String get walletCryptoActivity => 'Actividad de órdenes cripto';

  @override
  String get walletFundingTitle => 'Preparación para financiación cripto';

  @override
  String get walletFundingBody =>
      'Añade una cartera verificada antes de enviar fondos. La red, las comisiones, la caducidad de la cotización y el estado de liquidación se muestran antes de confirmar.';

  @override
  String get walletAddWallet => 'Añadir cartera verificada';

  @override
  String get walletVerificationStarted => 'Verificación de cartera iniciada';

  @override
  String get walletSettlementTitle => 'Se requiere confirmación de liquidación';

  @override
  String get walletSettlementBody =>
      'Las compras, retiros y cambios de cartera requieren confirmación final.';

  @override
  String get walletVerifiedBalance => 'Saldo de cartera verificada';

  @override
  String get portfolioCurrentValue => 'Valor actual del portafolio';

  @override
  String get portfolioInvested => 'Invertido';

  @override
  String get portfolioProfitLoss => 'Ganancia / pérdida';

  @override
  String get portfolioReturn => 'Rendimiento';

  @override
  String portfolioDividends(String amount) {
    return 'Dividendos recibidos: $amount';
  }

  @override
  String get portfolioHoldings => 'Posiciones';

  @override
  String get portfolioHoldingsEmptyBody =>
      'Las inversiones aprobadas aparecen aquí automáticamente.';

  @override
  String get portfolioAllocation => 'Asignación';

  @override
  String get portfolioAllocationEmptyTitle => 'Aún no hay asignación';

  @override
  String get portfolioAllocationEmptyBody =>
      'Tu combinación de activos aparece tras verificar los depósitos.';

  @override
  String portfolioInvestedOwnership(String invested, String ownership) {
    return 'Invertido $invested · $ownership de propiedad';
  }

  @override
  String get profileSettings => 'Ajustes';

  @override
  String profileThemeSubtitle(String mode) {
    return 'Tema $mode';
  }

  @override
  String get profileSecurityTitle => 'Seguridad y privacidad';

  @override
  String get profileSecuritySubtitle => 'Cartera verificada y biometría';

  @override
  String get profileDocumentsTitle => 'Documentos';

  @override
  String get profileDocumentsSubtitle =>
      'Estados de cuenta, divulgaciones de riesgo';

  @override
  String profileRowOpened(String title) {
    return '$title abierto';
  }

  @override
  String get profileSupport => 'Soporte';

  @override
  String get profileSupportSubtitle => 'Escribe al equipo de BrickClub';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileLogoutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get profileLogoutConfirmBody =>
      'Tendrás que iniciar sesión de nuevo para acceder a tu cuenta.';

  @override
  String get profileDefaultName => 'Miembro de BrickClub';

  @override
  String get profileDefaultSubtitle =>
      'Datos de tu cuenta y de tus BrickShares';

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
  String get themeAppearance => 'Apariencia';

  @override
  String get themeAppearanceDescription =>
      'Elige cómo se ve BrickClub en este dispositivo.';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystemDescription =>
      'Seguir este dispositivo automáticamente.';

  @override
  String get themeLightDescription =>
      'Usar una interfaz clara con texto oscuro.';

  @override
  String get themeDarkDescription =>
      'Usar la clásica interfaz oscura de BrickClub.';

  @override
  String get commonSending => 'Enviando…';

  @override
  String get commonSubmitting => 'Enviando…';

  @override
  String get filtersAssetClass => 'Clase de activo';

  @override
  String get filtersRiskLevel => 'Nivel de riesgo';

  @override
  String get filtersPaymentMethod => 'Método de pago';

  @override
  String get filtersReset => 'Restablecer';

  @override
  String filtersShow(int count) {
    return 'Mostrar $count';
  }

  @override
  String get successTitle => 'Comprobante enviado';

  @override
  String get successBody =>
      'Tu comprobante de pago está pendiente de verificación por el administrador. Te avisaremos tras la revisión.';

  @override
  String get successSettlementStatus => 'Estado de liquidación';

  @override
  String get successViewPortfolio => 'Ver portafolio';

  @override
  String get detailVerifiedDocs => 'Documentos verificados';

  @override
  String detailAssetLine(String assetClass, String location) {
    return '$assetClass BrickShares | $location';
  }

  @override
  String get detailLiquidity => 'Liquidez';

  @override
  String get detailFundingStatus => 'Estado de financiación';

  @override
  String detailFundedPercent(String percent) {
    return '$percent% financiado';
  }

  @override
  String get detailFundingNote =>
      'Las opciones de pago admitidas y la caducidad de la cotización se muestran antes de confirmar la liquidación.';

  @override
  String get detailInvestButton => 'Invertir con financiación cripto';

  @override
  String get kycStatusApproved =>
      'Las acciones financieras están desbloqueadas.';

  @override
  String get kycStatusSubmitted => 'Tus documentos están en revisión.';

  @override
  String get kycStatusRejectedDefault =>
      'Revisa la solicitud y vuelve a enviarla.';

  @override
  String get kycStatusDefault =>
      'Requerido antes de compras y cambios de cartera.';

  @override
  String get kycChipPhone => 'Teléfono';

  @override
  String get kycChipIdentity => 'Identidad';

  @override
  String get kycChipOk => 'OK';

  @override
  String get kycChipNeeded => 'Pendiente';

  @override
  String get kycViewDetails => 'Ver detalles del KYC';

  @override
  String get kycVerifyIdentity => 'Verificar identidad';

  @override
  String get kycFullName => 'Nombre legal completo';

  @override
  String get kycFullNameHint =>
      'Nombre exactamente como aparece en tu documento';

  @override
  String get kycDob => 'Fecha de nacimiento';

  @override
  String get kycSelectDate => 'Seleccionar fecha';

  @override
  String get kycGovId => 'Documento de identidad o pasaporte';

  @override
  String get kycUploadId => 'Subir documento de identidad';

  @override
  String get kycSelfie => 'Selfie / verificación facial';

  @override
  String get kycCaptureSelfie => 'Tomar selfie';

  @override
  String get kycAddressProof => 'Comprobante de domicilio físico';

  @override
  String get kycUploadAddress =>
      'Subir factura de servicios o contrato de alquiler';

  @override
  String get kycPhoneVerification => 'Verificación de teléfono';

  @override
  String get kycSendCode => 'Enviar código';

  @override
  String get kycVerificationCodeHint => 'Código de verificación';

  @override
  String get kycEmailVerification => 'Verificación de correo electrónico';

  @override
  String get kycEmailVerified => 'Correo electrónico verificado';

  @override
  String get kycEmailNotVerified => 'Correo electrónico no verificado';

  @override
  String get kycSendEmail => 'Enviar correo';

  @override
  String get kycSubmitForReview => 'Enviar para revisión';

  @override
  String get kycEmulatorNote =>
      'Los códigos de teléfono aparecen en el emulador de Firebase Auth. Los correos de desarrollo aparecen en Mailpit.';

  @override
  String get kycEmailSent => 'Correo de verificación enviado';

  @override
  String get kycEnterPhoneFirst => 'Introduce primero tu número de teléfono';

  @override
  String get kycCodeSent =>
      'Código enviado. Revisa el emulador de Firebase Auth.';

  @override
  String get kycSubmitted => 'KYC enviado para verificaciones automáticas';

  @override
  String get kycMissingName => 'Introduce tu nombre legal';

  @override
  String get kycMissingDob => 'Selecciona tu fecha de nacimiento';

  @override
  String get kycMissingId => 'Sube tu documento de identidad o pasaporte';

  @override
  String get kycMissingSelfie => 'Toma una selfie';

  @override
  String get kycMissingAddress => 'Sube un comprobante de domicilio';

  @override
  String get kycMissingPhone => 'Introduce tu número de teléfono';

  @override
  String get kycInvalidPhone =>
      'Introduce tu número de teléfono en formato internacional, p. ej. +12025550190.';

  @override
  String get kycMissingCode =>
      'Introduce el código de verificación de teléfono';

  @override
  String get kycUpdateFailed =>
      'No pudimos actualizar tus datos de KYC. Inténtalo de nuevo.';

  @override
  String get paymentConfirmFunding => 'Confirmar financiación';

  @override
  String get paymentSetup => 'Configuración de financiación cripto';

  @override
  String get paymentStatusDraft => 'Borrador';

  @override
  String get paymentStatusActive => 'Activo';

  @override
  String get paymentRail => 'Canal de pago';

  @override
  String get paymentAmount => 'Importe de la inversión';

  @override
  String get paymentAmountHint => 'Importe en USD';

  @override
  String paymentBelowMinimum(String minimum) {
    return 'El mínimo para esta oportunidad es $minimum.';
  }

  @override
  String get paymentDemoAmount =>
      'El importe de demostración se puede ajustar antes de crear la solicitud de depósito.';

  @override
  String get paymentQuotePaymentAsset => 'Activo de pago';

  @override
  String get paymentQuoteAmount => 'Importe';

  @override
  String get paymentQuoteNetwork => 'Red';

  @override
  String get paymentNetworkAfterRequest => 'Se selecciona tras la solicitud';

  @override
  String get paymentQuote => 'Cotización';

  @override
  String get paymentQuoteByBackend => 'Creada por el backend';

  @override
  String get paymentNetworkFee => 'Comisión de red';

  @override
  String get paymentFeeByBackend => 'Calculada por el backend';

  @override
  String get paymentSettlement => 'Liquidación';

  @override
  String get paymentPendingConfirmation => 'Pendiente de confirmación';

  @override
  String get paymentConfirmableTitle => 'Acción financiera confirmable';

  @override
  String get paymentConfirmableBody =>
      'Estás autorizando una compra de BrickShares financiada con cripto. La liquidación puede requerir confirmaciones de red.';

  @override
  String get paymentCreateRequest => 'Crear solicitud de depósito';

  @override
  String get paymentSubmitProof => 'Enviar comprobante para revisión';

  @override
  String get paymentIncreaseAmount =>
      'Aumenta el importe hasta el mínimo de la oportunidad.';

  @override
  String get paymentDepositCreated => 'Solicitud de depósito creada';

  @override
  String get paymentEnterHash => 'Introduce el hash de la transacción';

  @override
  String get paymentUploadProof => 'Sube el comprobante de pago';

  @override
  String get paymentDepositInstructions => 'Instrucciones de depósito';

  @override
  String get paymentWalletAddress => 'Dirección de la cartera';

  @override
  String get paymentTransactionHash => 'Hash de la transacción';

  @override
  String get paymentHashHint => 'Pega el hash de la transacción en blockchain';

  @override
  String get paymentReference => 'Referencia de pago';

  @override
  String get paymentReferenceHint =>
      'Ingresa el ID o la referencia de la transferencia';

  @override
  String get paymentStepQuote => 'Cotización';

  @override
  String get paymentStepSend => 'Enviar';

  @override
  String get paymentStepReview => 'Revisión';

  @override
  String get paymentCopy => 'Copiar';

  @override
  String get paymentWalletCopied => 'Dirección de cartera copiada';

  @override
  String get supportNewRequest => 'Nueva solicitud de soporte';

  @override
  String get supportNoRequestsTitle => 'Aún no hay solicitudes de soporte';

  @override
  String get supportNoRequestsBody =>
      'Inicia una conversación con el equipo de BrickClub cuando necesites ayuda con la cuenta, el KYC, la cartera o las inversiones.';

  @override
  String get supportSendRequest => 'Enviar solicitud';

  @override
  String get supportReplyTitle => 'Responder a soporte';

  @override
  String get supportSendReply => 'Enviar respuesta';

  @override
  String supportMessagesCount(int count) {
    return '$count mensajes';
  }

  @override
  String get supportRequestClosed => 'Solicitud cerrada';

  @override
  String get supportReply => 'Responder';

  @override
  String get supportTalkDirectly => 'Habla con nosotros directamente';

  @override
  String get supportTalkBody =>
      '¿Prefieres un chat rápido? Contacta al equipo de soporte de BrickClub por WhatsApp o Telegram para una ayuda más rápida.';

  @override
  String get supportNoMessagesYet => 'Aún no hay mensajes';

  @override
  String get supportTeamName => 'Soporte de BrickClub';

  @override
  String get supportYou => 'Tú';

  @override
  String get supportSubject => 'Asunto';

  @override
  String get supportSubjectHint => '¿Con qué necesitas ayuda?';

  @override
  String get supportMessage => 'Mensaje';

  @override
  String get supportMessageHint => 'Escribe tu mensaje';

  @override
  String get supportEnterSubject => 'Introduce un asunto';

  @override
  String get supportEnterMessage => 'Introduce un mensaje';

  @override
  String get supportMessageSent => 'Mensaje enviado';

  @override
  String supportCouldNotOpen(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navMore => 'Más';

  @override
  String get notificationsNone => 'No hay notificaciones nuevas';

  @override
  String get profileInMore => 'El perfil está en Más';

  @override
  String get investmentCardCryptoFunding => 'Financiación cripto';

  @override
  String get commonShowPassword => 'Mostrar contraseña';

  @override
  String get commonHidePassword => 'Ocultar contraseña';

  @override
  String get errAuthEmulatorUnreachable =>
      'La app no pudo conectar con el emulador de Firebase Auth. Recompila la app de depuración y asegúrate de que los emuladores de Firebase estén en ejecución.';

  @override
  String get errInvalidEmail => 'Introduce una dirección de correo válida.';

  @override
  String get errMissingEmail => 'Introduce tu dirección de correo.';

  @override
  String get errMissingPassword => 'Introduce tu contraseña.';

  @override
  String get errUserNotFound => 'No existe ninguna cuenta para ese correo.';

  @override
  String get errWrongPassword => 'El correo o la contraseña son incorrectos.';

  @override
  String get errEmailInUse => 'Ya existe una cuenta para ese correo.';

  @override
  String get errWeakPassword =>
      'Usa una contraseña más fuerte de al menos 6 caracteres.';

  @override
  String get errOperationNotAllowed =>
      'El inicio de sesión por correo aún no está habilitado. Contacta con soporte.';

  @override
  String get errUserDisabled =>
      'Esta cuenta ha sido deshabilitada. Contacta con soporte para obtener ayuda.';

  @override
  String get errTooManyRequests =>
      'Demasiados intentos. Espera un momento antes de volver a intentarlo.';

  @override
  String get errNetworkFailed =>
      'No pudimos conectar. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get errRequiresRecentLogin =>
      'Inicia sesión de nuevo antes de hacer este cambio.';

  @override
  String get errExpiredActionCode =>
      'Este enlace ha caducado. Solicita uno nuevo e inténtalo de nuevo.';

  @override
  String get errInvalidActionCode =>
      'Este enlace ya no es válido. Solicita uno nuevo e inténtalo de nuevo.';

  @override
  String get errAccountRequestFailed =>
      'No pudimos completar esa solicitud de cuenta. Inténtalo de nuevo.';

  @override
  String get errResetUnavailable =>
      'El correo de restablecimiento de contraseña no está disponible temporalmente. Inténtalo de nuevo en breve.';

  @override
  String get errResetNotAvailable =>
      'El restablecimiento de contraseña no está disponible ahora mismo.';

  @override
  String get errResetFailed =>
      'No pudimos enviar el correo de restablecimiento. Inténtalo de nuevo.';

  @override
  String get errSignInAgain => 'Inicia sesión de nuevo para continuar.';

  @override
  String get errAdminNoPermission =>
      'Tu cuenta no tiene permiso para hacer eso.';

  @override
  String get errEmailEnvUnavailable =>
      'El envío de correos no está disponible en este entorno.';

  @override
  String get errAddEmailFirst =>
      'Añade primero una dirección de correo a tu cuenta.';

  @override
  String get errPermissionDenied => 'No tienes permiso para hacer eso.';

  @override
  String get errGeneric => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get errKycInvalidCode => 'Introduce el código SMS del emulador.';

  @override
  String get errKycCredentialInUse =>
      'Ese número de teléfono ya está vinculado a otra cuenta.';

  @override
  String get errKycTooManyRequests =>
      'Demasiados intentos de verificación. Inténtalo más tarde.';

  @override
  String get errKycPhoneFailed =>
      'La verificación del teléfono falló. Inténtalo de nuevo.';

  @override
  String get errKycSignInAgain =>
      'Inicia sesión de nuevo para continuar con el KYC.';

  @override
  String get errKycNoPermission =>
      'No tienes permiso para actualizar este perfil de KYC.';

  @override
  String get errKycUnavailable =>
      'Los servicios de KYC no están disponibles temporalmente. Inténtalo de nuevo en breve.';

  @override
  String get errKycDeadline =>
      'La solicitud tardó demasiado. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get errKycStorageUnauthorized =>
      'No tienes permiso para subir este documento.';

  @override
  String get errKycStorageCanceled => 'La subida del documento se canceló.';

  @override
  String get errKycStorageRetry =>
      'La subida tardó demasiado. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get errKycStorageQuota =>
      'Las subidas de documentos no están disponibles temporalmente. Inténtalo de nuevo más tarde.';

  @override
  String get filterAll => 'Todos';

  @override
  String get enumAssetRealEstate => 'Bienes raíces';

  @override
  String get enumAssetReit => 'REIT';

  @override
  String get enumAssetEtf => 'ETF';

  @override
  String get enumAssetIndex => 'Fondo indexado';

  @override
  String get enumAssetAlternative => 'Alternativa';

  @override
  String get enumRiskConservative => 'Conservador';

  @override
  String get enumRiskBalanced => 'Equilibrado';

  @override
  String get enumRiskGrowth => 'Crecimiento';

  @override
  String get walletAddFundsTitle => 'Add funds to wallet';

  @override
  String get walletAddFundsSubtitle => 'Top up your spendable balance';

  @override
  String get investPlanTitle => 'Start an investment';

  @override
  String get investPlanNonePanel =>
      'No investment plans are available for this asset yet. Please check back soon.';

  @override
  String get investPlanAvailable => 'Available to invest';

  @override
  String get investPlanAmount => 'Amount to invest';

  @override
  String investPlanAmountHint(String min, String max) {
    return 'Between $min and $max';
  }

  @override
  String investPlanOutOfRange(String min, String max) {
    return 'Enter an amount between $min and $max.';
  }

  @override
  String get investPlanInsufficient =>
      'This is more than your wallet balance. Add funds first.';

  @override
  String investPlanBandApplied(String range) {
    return 'Plan tier: $range';
  }

  @override
  String get investPlanDuration => 'Lock duration';

  @override
  String get investPlanPrincipal => 'Principal';

  @override
  String get investPlanRate => 'Return rate';

  @override
  String get investPlanProfit => 'Projected profit';

  @override
  String get investPlanPayout => 'Total at maturity';

  @override
  String get investPlanMaturity => 'Matures on';

  @override
  String get investPlanDisclaimer =>
      'Profit is credited to your wallet as a lump sum when the plan matures.';

  @override
  String get investPlanConfirm => 'Confirm investment';

  @override
  String investPlanSuccess(String payout) {
    return 'Investment started. You will receive $payout at maturity.';
  }

  @override
  String portfolioExpectedProfit(String amount) {
    return 'Expected profit at maturity: $amount';
  }

  @override
  String get portfolioPlansTitle => 'Active investment plans';

  @override
  String portfolioPlanSummary(String rate, String duration, String date) {
    return '$rate for $duration · matures $date';
  }
}
