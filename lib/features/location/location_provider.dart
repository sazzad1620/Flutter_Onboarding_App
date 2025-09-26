import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationProvider extends ChangeNotifier {
  bool isLoading = false;
  String? currentAddress;

  Future<void> fetchLocation() async {
    isLoading = true;
    notifyListeners();

    try {
      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // Request permission if needed
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      // If permission still not granted, exit
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        currentAddress = "Permission not granted";
        isLoading = false;
        notifyListeners();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String city =
            place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            "";
        String country = place.country ?? "";

        currentAddress = city.isNotEmpty ? "$city, $country" : country;
      } else {
        currentAddress = "Location not found";
      }
    } catch (e) {
      currentAddress = "Error fetching location";
      print("LocationProvider error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
