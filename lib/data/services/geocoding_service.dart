import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:purificadora_app/env.dart';

class GeocodingService {
  final Dio _dio = Dio();

  Future<LatLng?> getCoordinates(String address) async {
  try {
    final response = await _dio.get(
      "https://maps.googleapis.com/maps/api/geocode/json",
      queryParameters: {
        "address": address,
        "key": googleAPIkey,
      },
    );

    final data = response.data;

    print("GEOCODING RESPONSE: $data"); 

    if (data["results"].isEmpty) return null;

    final location = data["results"][0]["geometry"]["location"];

    return LatLng(location["lat"], location["lng"]);
  } catch (e) {
    print("ERROR GEOCODING: $e"); 
    return null;
  }
}
}