import 'dart:async';

import 'package:flutter/material.dart' hide MapWidget;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

/// Position générique (latitude/longitude), indépendante du SDK carte.
/// `shared/` ne dépend jamais d'une feature (voir ARCHITECTURE.md §3) :
/// les features (`map`, `delivery`) convertissent leurs propres entités
/// domain vers ce type au moment d'appeler [MapWidget].
class LatLng {
  const LatLng({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class MapMarkerData {
  const MapMarkerData({required this.id, required this.position});

  final String id;
  final LatLng position;
}

/// Composant carte générique du Design System, consommé par `map` et
/// `delivery`. Enveloppe le SDK Mapbox (voir `CLAUDE.md` § AMENDEMENTS
/// 2026-07-03 — remplace Google Maps Flutter pour éviter la facturation
/// Google Cloud obligatoire sur ce POC) derrière une interface neutre
/// (`LatLng`/`MapMarkerData`) : un futur changement de fournisseur de
/// carte resterait cantonné à ce fichier.
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
    if (oldWidget.markers != widget.markers) {
      unawaited(_syncMarkers());
    }
    if (oldWidget.routePoints != widget.routePoints) {
      unawaited(_syncRoute());
    }
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
    await manager.deleteAll();
    for (final MapMarkerData marker in widget.markers) {
      await manager.create(
        mapbox.PointAnnotationOptions(geometry: _toPoint(marker.position)),
      );
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
