import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/firebase/backend_functions.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../domain/auth_credentials.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    BackendFunctions? backendFunctions,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _backendFunctions = backendFunctions ?? BackendFunctions();

  final FirebaseAuth _firebaseAuth;
  final BackendFunctions _backendFunctions;
  static const Duration _authTimeout = Duration(seconds: 12);

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
  }

  @override
  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');

    if (kIsWeb) {
      await _withAuthTimeout(_firebaseAuth.signInWithPopup(provider));
      return;
    }

    await _withAuthTimeout(_firebaseAuth.signInWithProvider(provider));
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

  Future<T> _withAuthTimeout<T>(Future<T> operation) {
    return operation.timeout(
      _authTimeout,
      onTimeout: () => throw const AuthOperationTimeoutException(
        'We could not reach Firebase Auth. Make sure the local Firebase emulators are running, then try again.',
      ),
    );
  }
}
