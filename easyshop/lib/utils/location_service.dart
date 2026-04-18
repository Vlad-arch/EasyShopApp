import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Fetches the current location and returns a human-readable address.
  Future<String?> getCurrentAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));

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
