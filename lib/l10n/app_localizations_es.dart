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
}
