import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<String> getCurrentAddress() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
    } else {
      return "Alamat tidak ditemukan";
    }
  } catch (e) {
    return "Error: $e";
  }
}
