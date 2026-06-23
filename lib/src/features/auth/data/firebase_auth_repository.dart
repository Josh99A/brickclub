import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/firebase/backend_functions.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../domain/auth_credentials.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    BackendFunctions? backendFunctions,
    FirebaseMessaging? firebaseMessaging,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _backendFunctions = backendFunctions ?? BackendFunctions(),
       _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  final FirebaseAuth _firebaseAuth;
  final BackendFunctions _backendFunctions;
  final FirebaseMessaging _firebaseMessaging;
  static const Duration _authTimeout = Duration(seconds: 30);
  static const Duration _messagingTimeout = Duration(seconds: 10);

  // Holds the web ConfirmationResult between sendPhoneVerificationCode and signInWithPhoneCode.
  ConfirmationResult? _webPhoneConfirmation;

  // FCM tokens rotate over time. We subscribe to onTokenRefresh once so a
  // rotated token is re-registered with the backend even without a fresh
  // sign-in; otherwise the server would keep pushing to a dead token.
  StreamSubscription<String>? _tokenRefreshSubscription;

  // Web push (FCM) needs the project's VAPID public key to mint a token. This
  // is a public key (it ships in client code), not a secret, and native
  // platforms ignore it — it sits alongside the other public Firebase web
  // options in DefaultFirebaseOptions.web. The web service worker lives at
  // web/firebase-messaging-sw.js. Override per-build with
  //   --dart-define=FCM_VAPID_KEY=...
  static const String _webVapidKey = String.fromEnvironment(
    'FCM_VAPID_KEY',
    defaultValue:
        'BOaJSAyv5kSBgBwFWsmcB2VeShMuIPlxSgmwPhI5K6rFj8QFSCzYr1ocSMsIfRLVlfY5c-jzHKFXJiFM1A_T29A',
  );

  @override
  Future<void> signIn(SignInCredentials credentials) async {
    final email = credentials.email.trim();
    if (email.isEmpty) {
      throw const AuthValidationException('Enter your email address.');
    }
    if (credentials.password.isEmpty) {
      throw const AuthValidationException('Enter your password.');
    }

    await _withAuthTimeout(
      _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: credentials.password,
      ),
    );
    _registerMessagingTokenInBackground();
  }

  @override
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      await _withAuthTimeout(_firebaseAuth.signInWithPopup(provider));
      _registerMessagingTokenInBackground();
      return;
    }

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _withAuthTimeout(_firebaseAuth.signInWithCredential(credential));
    _registerMessagingTokenInBackground();
  }

  @override
  Future<String> sendPhoneVerificationCode(String phoneNumber) async {
    final phone = phoneNumber.trim();
    if (phone.isEmpty) {
      throw const AuthValidationException('Enter your phone number.');
    }

    if (kIsWeb) {
      final confirmation = await _withAuthTimeout(
        _firebaseAuth.signInWithPhoneNumber(phone),
      );
      _webPhoneConfirmation = confirmation;
      return confirmation.verificationId;
    }

    // Mobile: verifyPhoneNumber uses callbacks; bridge to a Future via Completer.
    final completer = Completer<String>();
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: _authTimeout,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification (Android only).
        await _firebaseAuth.signInWithCredential(credential);
        _registerMessagingTokenInBackground();
        if (!completer.isCompleted) completer.complete('auto');
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(
            AuthValidationException(e.message ?? 'Phone verification failed.'),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
    );
    return completer.future;
  }

  @override
  Future<void> signInWithPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final code = smsCode.trim();
    if (code.isEmpty) {
      throw const AuthValidationException('Enter the verification code.');
    }

    if (kIsWeb) {
      final confirmation = _webPhoneConfirmation;
      if (confirmation == null) {
        throw const AuthValidationException(
          'Session expired. Please request a new code.',
        );
      }
      await _withAuthTimeout(confirmation.confirm(code));
      _webPhoneConfirmation = null;
    } else {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      await _withAuthTimeout(_firebaseAuth.signInWithCredential(credential));
    }
    _registerMessagingTokenInBackground();
  }

  @override
  Future<void> createAccount(SignUpCredentials credentials) async {
    final firstName = credentials.firstName.trim();
    final lastName = credentials.lastName.trim();
    final email = credentials.email.trim();
    if (firstName.isEmpty) {
      throw const AuthValidationException('Enter your legal first name.');
    }
    if (lastName.isEmpty) {
      throw const AuthValidationException('Enter your legal last name.');
    }
    if (email.isEmpty) {
      throw const AuthValidationException('Enter your email address.');
    }
    if (credentials.password.isEmpty) {
      throw const AuthValidationException('Create a password.');
    }
    if (credentials.password != credentials.confirmPassword) {
      throw const AuthValidationException('Passwords do not match.');
    }

    final userCredential = await _withAuthTimeout(
      _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: credentials.password,
      ),
    );

    await userCredential.user?.updateDisplayName('$firstName $lastName'.trim());
    _claimReferralCodeInBackground(credentials.referralCode);
    _registerMessagingTokenInBackground();
  }

  /// Records the inviter from a referral code without blocking signup. Like push
  /// registration, attribution is best-effort: a bad/duplicate code or a slow
  /// backend must never fail an otherwise successful account creation.
  void _claimReferralCodeInBackground(String referralCode) {
    final code = referralCode.trim();
    if (code.isEmpty) return;
    unawaited(
      _backendFunctions
          .claimReferralCode(code)
          .timeout(_messagingTimeout, onTimeout: () {})
          .catchError((_) {}),
    );
  }

  @override
  SignedInUserDetails? currentUserDetails() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return SignedInUserDetails(
      displayName: user.displayName,
      email: user.email,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    if (email.trim().isEmpty) {
      throw const AuthValidationException(
        'Enter your email address before requesting a reset.',
      );
    }

    if (FirebaseBootstrap.useEmulators) {
      return _withAuthTimeout(
        _backendFunctions.sendDevelopmentPasswordResetEmail(email),
      );
    }

    return _withAuthTimeout(
      _firebaseAuth.sendPasswordResetEmail(email: email.trim()),
    );
  }

  @override
  Future<bool> currentUserIsAdmin() async {
    final token = await _firebaseAuth.currentUser?.getIdTokenResult(true);
    return token?.claims?['admin'] == true;
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  /// Registers the device push token without blocking the sign-in flow.
  ///
  /// Push registration is best-effort: it must never delay or fail an
  /// otherwise successful sign-in. It runs detached from the auth call and is
  /// time-boxed so a slow or unconfigured messaging stack cannot hang the UI.
  void _registerMessagingTokenInBackground() {
    _listenForTokenRefresh();
    unawaited(
      _registerMessagingToken().timeout(
        _messagingTimeout,
        onTimeout: () {},
      ),
    );
  }

  // Subscribe once to FCM token rotations and re-register the new token. The
  // backend callable requires auth, so refreshes that fire while signed out
  // simply fail and are swallowed inside _registerMessagingToken.
  void _listenForTokenRefresh() {
    if (_tokenRefreshSubscription != null) return;
    if (kIsWeb && _webVapidKey.isEmpty) return;
    _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen(
      (token) {
        if (token.isEmpty) return;
        unawaited(
          _backendFunctions
              .registerMessagingToken(
                token: token,
                platform: defaultTargetPlatform.name,
              )
              .timeout(_messagingTimeout, onTimeout: () {})
              .catchError((_) {}),
        );
      },
      onError: (_) {},
    );
  }

  Future<void> _registerMessagingToken() async {
    // On web, FCM needs both the `firebase-messaging-sw.js` service worker
    // (present) and the project VAPID key. Without the key `getToken()` can
    // never succeed and may stall waiting on a service worker, so skip web
    // until the key is supplied via --dart-define=FCM_VAPID_KEY.
    if (kIsWeb && _webVapidKey.isEmpty) return;

    try {
      final settings = await _firebaseMessaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }
      final token = await _firebaseMessaging.getToken(
        vapidKey: kIsWeb ? _webVapidKey : null,
      );
      if (token == null || token.isEmpty) return;
      await _backendFunctions.registerMessagingToken(
        token: token,
        platform: defaultTargetPlatform.name,
      );
    } catch (_) {
      // Notification registration is best-effort and must not block sign-in.
    }
  }

  Future<T> _withAuthTimeout<T>(Future<T> operation) {
    return operation.timeout(
      _authTimeout,
      onTimeout: () => throw AuthOperationTimeoutException(
        FirebaseBootstrap.useEmulators
            ? 'We could not reach Firebase Auth at ${FirebaseBootstrap.emulatorHost}:9099. Make sure the local Firebase emulators are running, then try again.'
            : 'We could not reach Firebase Auth. Check your internet connection, then try again.',
      ),
    );
  }
}
