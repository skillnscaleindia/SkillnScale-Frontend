import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  String? _currentAddress;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<void> getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      _currentAddress = 'Location permission denied';
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (_currentPosition != null) {
        await _getAddressFromLatLng(_currentPosition!);
      }
    } catch (e) {
      _currentAddress = 'Could not get location';
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    if (kIsWeb) {
      await _reverseGeocodeWeb(position.latitude, position.longitude);
      return;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress = '${place.name}, ${place.locality}';
        if (_currentAddress == null || _currentAddress!.isEmpty) {
          _currentAddress = place.street;
        }
      }
    } catch (e) {
      // Fallback to web API
      await _reverseGeocodeWeb(position.latitude, position.longitude);
    }
  }

  /// Uses OpenStreetMap Nominatim (free, no API key) for reverse geocoding on web
  Future<void> _reverseGeocodeWeb(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'SkillnScale/1.0',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          // Build a short, readable address: neighbourhood/suburb, city
          final parts = <String>[];
          final neighbourhood = address['neighbourhood'] ?? address['suburb'] ?? address['hamlet'];
          final city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'];

          if (neighbourhood != null) parts.add(neighbourhood);
          if (city != null) parts.add(city);

          _currentAddress = parts.isNotEmpty ? parts.join(', ') : data['display_name'];
          return;
        }
      }
    } catch (_) {}

    // Final fallback
    _currentAddress = 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
  }
}
