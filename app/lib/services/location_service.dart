import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude, this.label);
  final double latitude;
  final double longitude;
  final String label;
}

/// Wraps browser/device geolocation plus free (no API key) geocoding via
/// OpenStreetMap's Nominatim, so "select your location" works without
/// needing a Google Maps/Places API key for this demo.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<GeoPoint> useCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are turned off.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission was denied.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
    final label = await _reverseGeocode(position.latitude, position.longitude);
    return GeoPoint(position.latitude, position.longitude, label);
  }

  Future<List<GeoPoint>> search(String query) async {
    if (query.trim().isEmpty) return const [];
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'format': 'json',
      'q': query,
      'limit': '5',
      'addressdetails': '1',
    });
    final response = await http.get(uri, headers: {'Accept': 'application/json'});
    if (response.statusCode != 200) return const [];
    final results = jsonDecode(response.body) as List;
    return results.map((r) {
      final map = r as Map<String, dynamic>;
      return GeoPoint(
        double.parse(map['lat'] as String),
        double.parse(map['lon'] as String),
        map['display_name'] as String,
      );
    }).toList();
  }

  Future<String> _reverseGeocode(double lat, double lon) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'json',
      'lat': '$lat',
      'lon': '$lon',
      'zoom': '14',
      'addressdetails': '1',
    });
    try {
      final response = await http.get(uri, headers: {'Accept': 'application/json'});
      if (response.statusCode != 200) return 'Current location';
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final address = map['address'] as Map<String, dynamic>?;
      final parts = [
        address?['suburb'] ?? address?['neighbourhood'] ?? address?['residential'],
        address?['city'] ?? address?['town'] ?? address?['village'],
      ].whereType<String>();
      return parts.isEmpty ? (map['display_name'] as String? ?? 'Current location') : parts.join(', ');
    } catch (_) {
      return 'Current location';
    }
  }

  /// Great-circle distance in kilometres.
  double distanceKm(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}
