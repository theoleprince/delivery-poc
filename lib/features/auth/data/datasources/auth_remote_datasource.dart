import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:poc_uber/core/constants/firestore_collections.dart';
import 'package:poc_uber/core/firestore/firestore_write_helpers.dart';
import 'package:poc_uber/features/auth/data/models/user_model.dart';

/// Encapsule tous les appels `FirebaseAuth`/`Firestore` liés à
/// l'authentification (voir ARCHITECTURE.md §4.3 : encapsulation au niveau
/// datasource, pas de couche `core/services` tant qu'une seule feature
/// consomme Firebase).
///
/// Ne traduit pas les erreurs : laisse `FirebaseAuthException` et les
/// erreurs Firestore se propager telles quelles, `AuthRepositoryImpl` est
/// responsable de leur conversion en `Failure` typée.
abstract interface class AuthRemoteDataSource {
  Stream<UserModel?> watchAuthState();

  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();

  Future<void> resetPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required fb.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  UserModel _toModel(fb.User user) => UserModel(
    uid: user.uid,
    email: user.email ?? '',
    displayName: user.displayName,
  );

  @override
  Stream<UserModel?> watchAuthState() {
    // Construit le modèle directement depuis `fb.User` (pas de lecture
    // Firestore à chaque changement d'état) : évite un aller-retour réseau
    // supplémentaire à chaque redémarrage de session pour un POC où seul
    // `auth` gère ces champs.
    return _firebaseAuth.authStateChanges().map(
      (fb.User? user) => user == null ? null : _toModel(user),
    );
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final fb.UserCredential credential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    final fb.User user = credential.user!;
    return _toModel(user);
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final fb.UserCredential credential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    final fb.User user = credential.user!;

    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
    }

    final UserModel model = UserModel(
      uid: user.uid,
      email: user.email ?? email,
      displayName: displayName,
    );

    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .set(attachTimestamps(model.toJson(), isCreate: true));

    return model;
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  Future<void> resetPassword({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
