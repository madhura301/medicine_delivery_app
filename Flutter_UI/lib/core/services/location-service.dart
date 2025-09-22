// location_service.dart
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? address;
  final String? error;

  LocationResult({
    required this.latitude,
    required this.longitude,
    this.address,
    this.error,
  });

  bool get hasError => error != null;
  bool get isValid => !hasError;
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Gets the current location with optional address geocoding
  Future<LocationResult> getCurrentLocation({
    bool includeAddress = true,
    Duration timeLimit = const Duration(seconds: 20),
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          latitude: 0,
          longitude: 0,
          error: 'Location services are disabled. Please enable GPS in your device settings.',
        );
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            latitude: 0,
            longitude: 0,
            error: 'Location permission denied. Please grant location access to continue.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Optionally open app settings
        await Geolocator.openAppSettings();
        return LocationResult(
          latitude: 0,
          longitude: 0,
          error: 'Location permission permanently denied. Please enable location access in device settings.',
        );
      }

      // Get current position with platform-specific settings
      Position position = await _getCurrentPosition(timeLimit);

      // Get address if requested
      String? address;
      if (includeAddress) {
        address = await _getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      }

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      return LocationResult(
        latitude: 0,
        longitude: 0,
        error: 'Unable to get location. Please check your GPS settings and try again.',
      );
    }
  }

  /// Get position with platform-specific optimizations
  Future<Position> _getCurrentPosition(Duration timeLimit) async {
    if (Platform.isIOS) {
      // iOS-specific settings
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: timeLimit,
      );
    } else {
      // Android-specific settings
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: timeLimit,
      );
    }
  }

  /// Get formatted address from coordinates
  Future<String?> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '';

        if (place.street?.isNotEmpty == true) address += '${place.street}, ';
        if (place.locality?.isNotEmpty == true) address += '${place.locality}, ';
        if (place.administrativeArea?.isNotEmpty == true) address += '${place.administrativeArea}';

        return address.isNotEmpty ? address : null;
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  /// Just get coordinates without address (faster)
  Future<LocationResult> getCoordinatesOnly({
    Duration timeLimit = const Duration(seconds: 15),
  }) async {
    return await getCurrentLocation(
      includeAddress: false,
      timeLimit: timeLimit,
    );
  }

  /// Check if location services are available
  Future<bool> isLocationServiceAvailable() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    return permission != LocationPermission.denied && 
           permission != LocationPermission.deniedForever;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission != LocationPermission.denied && 
           permission != LocationPermission.deniedForever;
  }
}