import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/firebase/backend_functions.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../domain/kyc_models.dart';
import '../domain/kyc_repository.dart';

class FirebaseKycRepository implements KycRepository {
  FirebaseKycRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    BackendFunctions? backendFunctions,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _backendFunctions = backendFunctions ?? BackendFunctions();

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final BackendFunctions _backendFunctions;
  String? _phoneVerificationId;
  PhoneAuthCredential? _autoPhoneCredential;

  @override
  Stream<KycProfile> watchProfile() {
    final user = _requireUser();
    return _firestore
        .collection('kycProfiles')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) => _profileFromSnapshot(snapshot, user));
  }

  @override
  Future<void> submit(KycSubmission submission) async {
    final user = _requireUser();
    await _verifyPhoneCode(submission);

    final basePath = 'kyc/${user.uid}/${DateTime.now().millisecondsSinceEpoch}';
    final documents = await Future.wait([
      _upload('$basePath/government-id', submission.governmentId),
      _upload('$basePath/selfie', submission.selfie),
      _upload('$basePath/address-proof', submission.addressProof),
    ]);

    await _backendFunctions.submitKycProfile({
      'fullLegalName': submission.fullLegalName.trim(),
      'dateOfBirth': submission.dateOfBirth.toIso8601String(),
      'phoneNumber': submission.phoneNumber.trim(),
      'documents': {
        'governmentId': documents[0].toJson(),
        'selfie': documents[1].toJson(),
        'addressProof': documents[2].toJson(),
      },
    });
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _requireUser();
    if (FirebaseBootstrap.useEmulators) {
      await _backendFunctions.sendDevelopmentEmailVerification();
      return;
    }

    await user.sendEmailVerification();
  }

  @override
  Future<void> sendPhoneVerificationCode(String phoneNumber) async {
    final user = _requireUser();
    final trimmedPhone = phoneNumber.trim();
    if (trimmedPhone.isEmpty) {
      throw const KycValidationException('Enter your phone number first.');
    }
    if (!_isE164PhoneNumber(trimmedPhone)) {
      throw const KycValidationException(
        'Enter your phone number in international format, e.g. +256774224734.',
      );
    }

    await _startPhoneVerification(trimmedPhone);

    await _firestore.collection('kycProfiles').doc(user.uid).set({
      'phoneNumber': trimmedPhone,
      'phoneVerified': false,
      'status': 'inProgress',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  User _requireUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const KycValidationException('Sign in to complete KYC.');
    }
    return user;
  }

  Future<_UploadedKycDocument> _upload(
    String path,
    KycDocumentFile file,
  ) async {
    final metadata = SettableMetadata(
      contentType: file.contentType,
      customMetadata: {'originalName': file.name},
    );
    final reference = _storage.ref(path);
    await reference.putData(file.bytes, metadata);
    return _UploadedKycDocument(
      path: reference.fullPath,
      downloadUrl: await reference.getDownloadURL(),
      contentType: file.contentType,
      originalName: file.name,
    );
  }

  Future<void> _startPhoneVerification(String phoneNumber) async {
    final completer = Completer<void>();
    _phoneVerificationId = null;
    _autoPhoneCredential = null;

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) {
          _autoPhoneCredential = credential;
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (error) {
          if (!completer.isCompleted) {
            completer.completeError(KycValidationException(_phoneError(error)));
          }
        },
        codeSent: (verificationId, _) {
          _phoneVerificationId = verificationId;
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _phoneVerificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (error) {
      throw KycValidationException(_phoneError(error));
    }

    await completer.future;
  }

  Future<void> _verifyPhoneCode(KycSubmission submission) async {
    final credential =
        _autoPhoneCredential ??
        PhoneAuthProvider.credential(
          verificationId: _requirePhoneVerificationId(),
          smsCode: submission.phoneVerificationCode.trim(),
        );

    try {
      await _requireUser().linkWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      if (error.code != 'provider-already-linked') {
        throw KycValidationException(_phoneError(error));
      }
    }
  }

  String _requirePhoneVerificationId() {
    final verificationId = _phoneVerificationId;
    if (verificationId == null) {
      throw const KycValidationException(
        'Send a phone verification code first.',
      );
    }

    return verificationId;
  }

  String _phoneError(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-phone-number' =>
        'Enter your phone number in international format, e.g. +256774224734.',
      'invalid-verification-code' => 'Enter the SMS code from the emulator.',
      'credential-already-in-use' =>
        'That phone number is already linked to another account.',
      'too-many-requests' => 'Too many verification attempts. Try again later.',
      _ => error.message ?? 'Phone verification failed. Please try again.',
    };
  }

  bool _isE164PhoneNumber(String phoneNumber) {
    return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phoneNumber);
  }

  KycProfile _profileFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    User user,
  ) {
    final data = snapshot.data();
    if (data == null) {
      return KycProfile(
        status: KycStatus.notStarted,
        emailVerified: user.emailVerified,
        phoneVerified: false,
      );
    }

    return KycProfile(
      status: _statusFromString((data['status'] ?? 'notStarted').toString()),
      emailVerified: user.emailVerified || data['emailVerified'] == true,
      phoneVerified: data['phoneVerified'] == true,
      fullLegalName: data['fullLegalName'] as String?,
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      phoneNumber: data['phoneNumber'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  KycStatus _statusFromString(String value) {
    return switch (value) {
      'inProgress' => KycStatus.inProgress,
      'submitted' => KycStatus.submitted,
      'approved' => KycStatus.approved,
      'rejected' => KycStatus.rejected,
      _ => KycStatus.notStarted,
    };
  }
}

class _UploadedKycDocument {
  const _UploadedKycDocument({
    required this.path,
    required this.downloadUrl,
    required this.contentType,
    required this.originalName,
  });

  final String path;
  final String downloadUrl;
  final String contentType;
  final String originalName;

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'downloadUrl': downloadUrl,
      'contentType': contentType,
      'originalName': originalName,
    };
  }
}
