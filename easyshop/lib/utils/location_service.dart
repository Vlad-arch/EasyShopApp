import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Returns the current raw position of the user.
  Future<Position?> getUserPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
  }

  // Static cache to store geocoded coordinates for shop addresses
  static final Map<String, Location> _geocodeCache = {};

  /// Returns coordinates (lat, long) for a given address string, with caching.
  Future<Location?> getCoordinatesFromAddress(String address) async {
    if (_geocodeCache.containsKey(address)) {
      return _geocodeCache[address];
    }
    
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        _geocodeCache[address] = locations[0];
        return locations[0];
      }
    } catch (e) {
      print("Error geocoding address ($address): $e");
    }
    return null;
  }

  /// Checks if a store is within the specified radius (in km).
  Future<bool> isStoreNearby({
    required Position userPosition,
    required String shopAddress,
    double radiusKm = 150.0,
  }) async {
    final shopLoc = await getCoordinatesFromAddress(shopAddress);
    if (shopLoc == null) return true; // Fallback to visible if geocoding fails

    double distance = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      shopLoc.latitude,
      shopLoc.longitude,
    );

    return distance <= (radiusKm * 1000);
  }

  /// Fetches the current location and returns a human-readable address.
  Future<String?> getCurrentAddress() async {
    Position? position = await getUserPosition();
    if (position == null) return null;

    // Reverse geocode the coordinates
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Standard Italian address format or general fallback
        String address = "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
        
        // Clean up empty fields if necessary
        address = address.replaceAll(RegExp(r',\s*,'), ',').trim();
        if (address.startsWith(',')) address = address.substring(1).trim();
        if (address.endsWith(',')) address = address.substring(0, address.length - 1).trim();
        
        return address;
      }
    } catch (e) {
      return Future.error('Error during geocoding: $e');
    }

    return null;
  }
}
