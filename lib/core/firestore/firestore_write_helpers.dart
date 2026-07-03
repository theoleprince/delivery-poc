import 'package:cloud_firestore/cloud_firestore.dart';

/// Ajoute les horodatages standard à un document avant écriture Firestore.
/// `updatedAt` est toujours renseigné ; `createdAt` seulement à la création
/// (il ne doit jamais être réécrit sur un document existant).
///
/// Partagé entre toutes les datasources qui écrivent dans Firestore (voir
/// ARCHITECTURE.md §4.3 : introduit dès la 2e feature consommatrice, pour
/// éviter de dupliquer cette logique dans chaque datasource).
Map<String, Object?> attachTimestamps(
  Map<String, Object?> json, {
  required bool isCreate,
}) {
  return <String, Object?>{
    ...json,
    if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
