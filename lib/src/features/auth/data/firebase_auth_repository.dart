import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Future<void> signIn(SignInCredentials credentials) async {
    final email = credentials.email.trim();
    if (email.isEmpty) {
      throw const AuthValidationException('Enter your email address.');
    }
    if (credentials.password.isEmpty) {
      throw const AuthValidationException('Enter your password.');
    }

    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: credentials.password,
    );
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

    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: credentials.password,
    );

    await userCredential.user?.updateDisplayName(
      '$firstName $lastName'.trim(),
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
      return _backendFunctions.sendDevelopmentPasswordResetEmail(email);
    }

    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<bool> currentUserIsAdmin() async {
    final token = await _firebaseAuth.currentUser?.getIdTokenResult(true);
    return token?.claims?['admin'] == true;
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}

class AuthValidationException implements Exception {
  const AuthValidationException(this.message);

  final String message;
}
