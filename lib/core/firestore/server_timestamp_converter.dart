import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Convertit les `Timestamp` Firestore en `DateTime` et inversement, pour
/// que les modèles `data` restent sérialisables en JSON standard
/// (`json_serializable` ne sait pas nativement gérer le type `Timestamp`).
/// Partagé entre toutes les features qui persistent des dates dans
/// Firestore (voir `firestore_write_helpers.dart` pour le pendant côté
/// écriture).
class ServerTimestampConverter implements JsonConverter<DateTime?, Object?> {
  const ServerTimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    return null;
  }

  @override
  Object? toJson(DateTime? object) =>
      object == null ? null : Timestamp.fromDate(object);
}
