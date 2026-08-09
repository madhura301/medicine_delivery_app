import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pharmaish/core/services/location_service.dart';
import 'package:pharmaish/core/theme/app_theme.dart';

/// Full-screen map on which the user positions a centre pin to pick ANY
/// location (not just their current GPS position). Uses OpenStreetMap tiles —
/// no API key required.
///
/// Returns the chosen [LocationResult] (coordinates + reverse-geocoded address)
/// via `Navigator.pop`, or `null` if the user backs out.
///
/// Convenience launcher:
/// ```dart
/// final result = await pickLocationOnMap(context,
///     initialLatitude: _latitude, initialLongitude: _longitude);
/// if (result != null) { /* store result.latitude/longitude, fill fields */ }
/// ```
Future<LocationResult?> pickLocationOnMap(
  BuildContext context, {
  double? initialLatitude,
  double? initialLongitude,
}) {
  return Navigator.of(context).push<LocationResult>(
    MaterialPageRoute(
      builder: (_) => MapLocationPickerPage(
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
      ),
    ),
  );
}

class MapLocationPickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapLocationPickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapLocationPickerPage> createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  // Geographic centre of India — a sensible fallback when we have no hint.
  static const LatLng _fallbackCenter = LatLng(20.5937, 78.9629);
  static const double _pickZoom = 16;

  late LatLng _center;
  String? _addressPreview;
  bool _isResolving = false;
  bool _isLocating = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final hasInitial =
        widget.initialLatitude != null && widget.initialLongitude != null;
    _center = hasInitial
        ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : _fallbackCenter;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasInitial) {
        _resolveAddress(_center);
      } else {
        // No hint — jump to the device's current location to start near the user.
        _goToCurrentLocation(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _center = camera.center;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (mounted) _resolveAddress(_center);
    });
  }

  Future<void> _resolveAddress(LatLng point) async {
    setState(() => _isResolving = true);
    final result = await _locationService.getAddressFromCoordinates(
        point.latitude, point.longitude);
    if (!mounted) return;
    setState(() {
      _isResolving = false;
      _addressPreview = (result.address?.isNotEmpty ?? false)
          ? result.address
          : '${point.latitude.toStringAsFixed(6)}, '
              '${point.longitude.toStringAsFixed(6)}';
    });
  }

  Future<void> _goToCurrentLocation({bool silent = false}) async {
    setState(() => _isLocating = true);
    final result =
        await _locationService.getCurrentLocation(includeAddress: false);
    if (!mounted) return;
    setState(() => _isLocating = false);

    if (result.isValid && result.latitude != 0) {
      final p = LatLng(result.latitude, result.longitude);
      _center = p;
      _mapController.move(p, _pickZoom);
      _resolveAddress(p);
    } else if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Unable to get current location')),
      );
    }
  }

  Future<void> _confirm() async {
    setState(() => _isResolving = true);
    final result = await _locationService.getAddressFromCoordinates(
        _center.latitude, _center.longitude);
    if (!mounted) return;
    // Always return the chosen coordinates, even if reverse-geocoding failed.
    final out = (result.address?.isNotEmpty ?? false)
        ? result
        : LocationResult(
            latitude: _center.latitude, longitude: _center.longitude);
    Navigator.pop(context, out);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _pickZoom,
              minZoom: 3,
              maxZoom: 19,
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pharmaish.app',
              ),
            ],
          ),

          // Fixed centre pin — its tip points at the map centre.
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: const Icon(Icons.location_pin,
                    size: 48, color: AppTheme.primaryColor),
              ),
            ),
          ),

          // Hint banner at the top.
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: IgnorePointer(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Drag the map to position the pin on your exact location',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),

          // Address preview + confirm button at the bottom.
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.place,
                            size: 18, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _isResolving
                              ? Row(
                                  children: [
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Finding address…',
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13)),
                                  ],
                                )
                              : Text(
                                  _addressPreview ?? 'Move the map to pick a spot',
                                  style: const TextStyle(fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isResolving ? null : _confirm,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Confirm this location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 130),
        child: FloatingActionButton(
          onPressed: _isLocating ? null : () => _goToCurrentLocation(),
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          tooltip: 'Go to current location',
          child: _isLocating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location),
        ),
      ),
    );
  }
}
