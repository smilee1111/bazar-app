import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bazar/core/services/location/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Represents current user location with nullable values
class UserLocation {
  final double latitude;
  final double longitude;
  final DateTime fetchedAt;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.fetchedAt,
  });

  /// Calculate distance to another location in kilometers
  double distanceTo(double lat, double lng) {
    const Distance distance = Distance();
    return distance.as(
      LengthUnit.Kilometer,
      LatLng(latitude, longitude),
      LatLng(lat, lng),
    );
  }

  @override
  String toString() =>
      'UserLocation(lat: $latitude, lng: $longitude, fetchedAt: $fetchedAt)';
}

/// Geolocation State
class GeolocationState {
  final UserLocation? userLocation;
  final bool isLoading;
  final String? errorMessage;
  final bool isLocationEnabled;
  final LocationPermission? lastPermissionStatus;

  const GeolocationState({
    this.userLocation,
    this.isLoading = false,
    this.errorMessage,
    this.isLocationEnabled = true,
    this.lastPermissionStatus,
  });

  GeolocationState copyWith({
    UserLocation? userLocation,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isLocationEnabled,
    LocationPermission? lastPermissionStatus,
  }) {
    return GeolocationState(
      userLocation: userLocation ?? this.userLocation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      lastPermissionStatus: lastPermissionStatus ?? this.lastPermissionStatus,
    );
  }
}

/// Geolocation Notifier - manages user location state
class GeolocationNotifier extends Notifier<GeolocationState> {
  late final LocationService _locationService;

  @override
  GeolocationState build() {
    _locationService = ref.read(locationServiceProvider);
    return const GeolocationState();
  }

  /// Request and fetch user's current location
  Future<UserLocation?> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Check location service status first
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        state = state.copyWith(
          isLoading: false,
          isLocationEnabled: false,
          errorMessage: 'Location service is disabled. Please enable it in settings.',
        );
        return null;
      }

      state = state.copyWith(isLocationEnabled: true);

      // Check and request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      state = state.copyWith(lastPermissionStatus: permission);

      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Location permission denied',
        );
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Location permission denied permanently. Please enable it in app settings.',
        );
        return null;
      }

      // Get current position
      final latLng = await _locationService.getCurrentLocation();

      if (latLng == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch location',
        );
        return null;
      }

      final userLocation = UserLocation(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        fetchedAt: DateTime.now(),
      );

      state = state.copyWith(
        userLocation: userLocation,
        isLoading: false,
        clearError: true,
      );

      return userLocation;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );
      return null;
    }
  }

  /// Clear stored location
  void clearLocation() {
    state = state.copyWith(userLocation: null, clearError: true);
  }
}

/// Riverpod provider for geolocation state management
final geolocationProvider =
    NotifierProvider<GeolocationNotifier, GeolocationState>(
  GeolocationNotifier.new,
);
