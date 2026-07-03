import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';

/// Libellé affiché pour un `DeliveryStatus` — partagé entre
/// `DeliveryHistoryPage`, `DeliveryDetailPage` et `TrackingPage` (feature
/// `tracking`) pour éviter de dupliquer ce `switch` trois fois.
String deliveryStatusLabel(DeliveryStatus status) {
  switch (status) {
    case DeliveryStatus.pending:
      return 'En attente de prise en charge';
    case DeliveryStatus.pickedUp:
      return 'Récupérée par le livreur';
    case DeliveryStatus.inTransit:
      return 'En cours de livraison';
    case DeliveryStatus.delivered:
      return 'Livrée';
  }
}
