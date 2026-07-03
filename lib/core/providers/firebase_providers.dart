import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

/// Instances Firebase partagées entre toutes les features (voir
/// ARCHITECTURE.md §4.3 : introduites dans `core` dès que 2 features
/// (`auth`, `delivery`) en ont besoin, pour éviter de dupliquer
/// `FirebaseFirestore.instance`/`FirebaseAuth.instance` dans chaque
/// provider de feature).
@riverpod
fb.FirebaseAuth firebaseAuth(Ref ref) => fb.FirebaseAuth.instance;

@riverpod
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;
