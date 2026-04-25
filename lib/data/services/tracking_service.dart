import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:purificadora_app/data/repositories/directions_repository.dart';
import 'package:purificadora_app/domain/models/directions.dart';

class TrackingService {
  final DirectionsRepository _directionsRepository;

  TrackingService({DirectionsRepository? directionsRepository})
    : _directionsRepository = directionsRepository ?? DirectionsRepository();

  /// =========================
  /// 📍 UBICACIÓN ACTUAL
  /// =========================
  Future<LatLng> getCurrentLocation() async {
    final position = await _determinePosition();

    return LatLng(position.latitude, position.longitude);
  }

  /// =========================
  /// 📡 STREAM DE UBICACIÓN
  /// =========================
  Stream<LatLng> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // metros
      ),
    ).map((position) {
      return LatLng(position.latitude, position.longitude);
    });
  }

  /// =========================
  /// 🗺️ OBTENER RUTA
  /// =========================
  Future<Directions?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    return await _directionsRepository.getDirections(
      origin: origin,
      destination: destination,
    );
  }

  /// =========================
  /// 📌 CREAR MARKERS
  /// =========================
  Set<Marker> buildMarkers({
    required LatLng origin,
    required LatLng destination,
  }) {
    return {
      Marker(
        markerId: const MarkerId('origin'),
        position: origin,
        infoWindow: const InfoWindow(title: 'Repartidor'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: const InfoWindow(title: 'Destino'),
      ),
    };
  }

  /// =========================
  /// 📍 CREAR POLYLINE
  /// =========================
  Set<Polyline> buildPolyline(Directions? directions) {
    if (directions == null) return {};

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        color: const Color(0xFF1565C0),
        width: 5,
        points: directions.polylinePoints
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList(),
      ),
    };
  }

  /// =========================
  /// PERMISOS Y GPS
  /// =========================
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // GPS activo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS desactivado');
    }

    // Permisos
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Permiso denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permiso denegado permanentemente');
    }

    return await Geolocator.getCurrentPosition();
  }
}
