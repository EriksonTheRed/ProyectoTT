import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingService {

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
        distanceFilter: 10,
      ),
    ).map((position) {
      return LatLng(position.latitude, position.longitude);
    });
  }

  /// =========================
  /// PERMISOS Y GPS
  /// =========================
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS desactivado');
    }

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