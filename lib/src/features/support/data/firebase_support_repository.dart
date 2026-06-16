import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../domain/support_models.dart';
import '../domain/support_repository.dart';

class FirebaseSupportRepository implements SupportRepository {
  FirebaseSupportRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  @override
  Stream<List<SupportTicket>> watchMyTickets() {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);

    return _firestore
        .collection('supportTickets')
        .where('uid', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportTicket.fromJson(_ticketJson(doc)))
              .toList(growable: false),
        );
  }

  @override
  Future<void> createTicket({
    required String subject,
    required String message,
  }) async {
    await _call('createSupportTicket', {
      'subject': subject.trim(),
      'message': message.trim(),
    });
  }

  @override
  Future<void> replyToTicket({
    required String ticketId,
    required String message,
  }) async {
    await _call('replyToSupportTicket', {
      'ticketId': ticketId,
      'message': message.trim(),
    });
  }

  Future<void> _call(String name, Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable(name);
    await callable.call<Object?>(data);
  }

  Map<String, dynamic> _ticketJson(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return {..._normalize(doc.data()), 'id': doc.id};
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, _normalizeValue(value)));
  }

  Object? _normalizeValue(Object? value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is List) return value.map(_normalizeValue).toList();
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), _normalizeValue(item)),
      );
    }
    return value;
  }
}
