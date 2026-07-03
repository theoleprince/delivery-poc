import 'dart:async';

import 'package:flutter/material.dart' hide MapWidget;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

/// Position générique (latitude/longitude), indépendante du SDK carte.
/// `shared/` ne dépend jamais d'une feature (voir ARCHITECTURE.md §3) :
/// les features (`map`, `delivery`, `tracking`) convertissent leurs propres
/// entités domain vers ce type au moment d'appeler [MapWidget].
class LatLng {
  const LatLng({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  /// Interpolation linéaire entre deux points — utilisée par `tracking`
  /// pour animer le marqueur du livreur entre deux positions Firestore
  /// (voir ARCHITECTURE.md §11.3).
  static LatLng lerp(LatLng a, LatLng b, double t) => LatLng(
    latitude: a.latitude + (b.latitude - a.latitude) * t,
    longitude: a.longitude + (b.longitude - a.longitude) * t,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LatLng &&
          other.latitude == latitude &&
          other.longitude == longitude);

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

class MapMarkerData {
  const MapMarkerData({required this.id, required this.position});

  final String id;
  final LatLng position;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapMarkerData && other.id == id && other.position == position);

  @override
  int get hashCode => Object.hash(id, position);
}

/// Composant carte générique du Design System, consommé par `map`,
/// `delivery` et `tracking`. Enveloppe le SDK Mapbox (voir `CLAUDE.md` §
/// AMENDEMENTS 2026-07-03 — remplace Google Maps Flutter pour éviter la
/// facturation Google Cloud obligatoire sur ce POC) derrière une interface
/// neutre (`LatLng`/`MapMarkerData`) : un futur changement de fournisseur
/// de carte resterait cantonné à ce fichier.
///
/// Les marqueurs existants sont mis à jour **en place** (`update`) plutôt
/// que supprimés/recréés à chaque changement — nécessaire pour une
/// "animation fluide du marqueur" (`tracking`, plusieurs mises à jour par
/// seconde) sans à-coups ni recréation coûteuse côté SDK natif.
///
/// ATTENTION : l'API des annotations Mapbox (`PointAnnotationManager`,
/// `PolylineAnnotationOptions`, ...) n'a pas pu être compilée dans cet
/// environnement (SDK Flutter indisponible). C'est le premier fichier à
/// vérifier avec `flutter analyze` contre la version exacte de
/// `mapbox_maps_flutter` résolue par `pub get`.
class MapWidget extends StatefulWidget {
  const MapWidget({
    required this.initialCenter,
    this.initialZoom = 14,
    this.markers = const <MapMarkerData>[],
    this.routePoints,
    this.onTap,
    super.key,
  });

  final LatLng initialCenter;
  final double initialZoom;
  final List<MapMarkerData> markers;

  /// Si fourni (>= 2 points), trace une polyline reliant ces points — voir
  /// ARCHITECTURE.md §8 : trajet simulé en ligne droite pour ce POC.
  final List<LatLng>? routePoints;
  final ValueChanged<LatLng>? onTap;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  mapbox.PointAnnotationManager? _pointAnnotationManager;
  mapbox.PolylineAnnotationManager? _polylineAnnotationManager;

  /// Suivi des annotations Mapbox déjà créées, par id de marqueur — permet
  /// de les mettre à jour en place au lieu de tout recréer.
  final Map<String, mapbox.PointAnnotation> _markerAnnotations =
      <String, mapbox.PointAnnotation>{};
  final Map<String, LatLng> _lastMarkerPositions = <String, LatLng>{};

  @override
  Widget build(BuildContext context) {
    return mapbox.MapWidget(
      cameraOptions: mapbox.CameraOptions(
        center: _toPoint(widget.initialCenter),
        zoom: widget.initialZoom,
      ),
      onMapCreated: _onMapCreated,
      onTapListener: widget.onTap == null ? null : _handleTap,
    );
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `_syncMarkers` compare position par position et ignore les marqueurs
    // inchangés : appel systématique sans coût significatif, plutôt que de
    // comparer des `List` par référence (toujours différentes, une nouvelle
    // liste étant créée à chaque build par les appelants).
    unawaited(_syncMarkers());
    if (!_routePointsEqual(oldWidget.routePoints, widget.routePoints)) {
      unawaited(_syncRoute());
    }
  }

  bool _routePointsEqual(List<LatLng>? a, List<LatLng>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _handleTap(mapbox.MapContentGestureContext context) {
    final mapbox.Position position = context.point.coordinates;
    widget.onTap?.call(
      LatLng(latitude: position.lat.toDouble(), longitude: position.lng.toDouble()),
    );
  }

  Future<void> _onMapCreated(mapbox.MapboxMap mapboxMap) async {
    _pointAnnotationManager = await mapboxMap.annotations
        .createPointAnnotationManager();
    _polylineAnnotationManager = await mapboxMap.annotations
        .createPolylineAnnotationManager();
    await _syncMarkers();
    await _syncRoute();
  }

  Future<void> _syncMarkers() async {
    final mapbox.PointAnnotationManager? manager = _pointAnnotationManager;
    if (manager == null) return;

    final Set<String> currentIds = widget.markers
        .map((MapMarkerData marker) => marker.id)
        .toSet();

    for (final String staleId in _markerAnnotations.keys
        .where((String id) => !currentIds.contains(id))
        .toList()) {
      await manager.delete(_markerAnnotations.remove(staleId)!);
      _lastMarkerPositions.remove(staleId);
    }

    for (final MapMarkerData marker in widget.markers) {
      if (_lastMarkerPositions[marker.id] == marker.position) continue;
      _lastMarkerPositions[marker.id] = marker.position;

      final mapbox.PointAnnotation? existing = _markerAnnotations[marker.id];
      if (existing == null) {
        _markerAnnotations[marker.id] = await manager.create(
          mapbox.PointAnnotationOptions(geometry: _toPoint(marker.position)),
        );
      } else {
        existing.geometry = _toPoint(marker.position);
        await manager.update(existing);
      }
    }
  }

  Future<void> _syncRoute() async {
    final mapbox.PolylineAnnotationManager? manager =
        _polylineAnnotationManager;
    if (manager == null) return;
    await manager.deleteAll();
    final List<LatLng>? points = widget.routePoints;
    if (points == null || points.length < 2) return;
    await manager.create(
      mapbox.PolylineAnnotationOptions(
        geometry: mapbox.LineString(
          coordinates: points.map(_toPosition).toList(),
        ),
        lineColor: Colors.blue.value,
        lineWidth: 4,
      ),
    );
  }

  mapbox.Point _toPoint(LatLng latLng) =>
      mapbox.Point(coordinates: _toPosition(latLng));

  mapbox.Position _toPosition(LatLng latLng) =>
      mapbox.Position(latLng.longitude, latLng.latitude);
}
