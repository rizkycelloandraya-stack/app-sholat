import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String readableName;
  final String districtProvince; // e.g. "Kecamatan Cibiru, Jawa Barat, Indonesia"
  final String fullAddress; // e.g. "Pasir Biru, Kec. Cibiru, Kota Bandung, Jawa Barat 40615, Indonesia"
  final bool isAccurateGps;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.readableName,
    this.districtProvince = '',
    this.fullAddress = '',
    required this.isAccurateGps,
  });
}

class LocationService {
  static const double defaultLatitude = -6.92969;
  static const double defaultLongitude = 107.721869;
  static const String defaultLocationName = 'Kecamatan Cibiru, Kota Bandung';
  static const String defaultDistrictProvince = 'Kecamatan Cibiru, Jawa Barat, Indonesia';
  static const String defaultFullAddress = 'Pasir Biru, Kec. Cibiru, Kota Bandung, Jawa Barat 40615, Indonesia';

  /// Obtain current GPS coordinates with reverse geocoded detailed address components.
  static Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          latitude: defaultLatitude,
          longitude: defaultLongitude,
          readableName: defaultLocationName,
          districtProvince: defaultDistrictProvince,
          fullAddress: defaultFullAddress,
          isAccurateGps: false,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return const LocationResult(
            latitude: defaultLatitude,
            longitude: defaultLongitude,
            readableName: defaultLocationName,
            districtProvince: defaultDistrictProvince,
            fullAddress: defaultFullAddress,
            isAccurateGps: false,
          );
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 7),
        ),
      );

      final addressInfo = await getDetailedAddress(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        readableName: addressInfo['readableName'] ?? defaultLocationName,
        districtProvince: addressInfo['districtProvince'] ?? defaultDistrictProvince,
        fullAddress: addressInfo['fullAddress'] ?? defaultFullAddress,
        isAccurateGps: true,
      );
    } catch (_) {
      return const LocationResult(
        latitude: defaultLatitude,
        longitude: defaultLongitude,
        readableName: defaultLocationName,
        districtProvince: defaultDistrictProvince,
        fullAddress: defaultFullAddress,
        isAccurateGps: false,
      );
    }
  }

  /// Reverse geocodes coordinates to detailed address components
  static Future<Map<String, String>> getDetailedAddress({
    required double latitude,
    required double longitude,
  }) async {
    if (kIsWeb) {
      return {
        'readableName': defaultLocationName,
        'districtProvince': defaultDistrictProvince,
        'fullAddress': defaultFullAddress,
      };
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(const Duration(seconds: 4));

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final street = p.street ?? '';
        final subLocality = p.subLocality ?? ''; // Kelurahan / Desa
        final locality = p.locality ?? ''; // Kecamatan
        final subAdmin = p.subAdministrativeArea ?? ''; // Kota / Kab
        final admin = p.administrativeArea ?? ''; // Provinsi
        final postal = p.postalCode ?? '';
        final country = p.country ?? 'Indonesia';

        // 1. Readable Short Name (e.g. "Kecamatan Cibiru, Kota Bandung")
        final shortParts = <String>[];
        if (locality.isNotEmpty) shortParts.add(locality.startsWith('Kec') ? locality : 'Kec. $locality');
        if (subAdmin.isNotEmpty) shortParts.add(subAdmin);
        final readableName = shortParts.isNotEmpty ? shortParts.join(', ') : '$subAdmin, $admin';

        // 2. District & Province Line (e.g. "Kecamatan Cibiru, Jawa Barat, Indonesia")
        final distParts = <String>[];
        if (locality.isNotEmpty) {
          distParts.add(locality.startsWith('Kec') ? locality : 'Kecamatan $locality');
        }
        if (admin.isNotEmpty) distParts.add(admin);
        if (country.isNotEmpty) distParts.add(country);
        final districtProvince = distParts.join(', ');

        // 3. Full Address Line (e.g. "Pasir Biru, Kec. Cibiru, Kota Bandung, Jawa Barat 40615, Indonesia")
        final fullParts = <String>[];
        if (street.isNotEmpty && !street.contains('+') && !street.contains('Unnamed')) fullParts.add(street);
        if (subLocality.isNotEmpty) fullParts.add(subLocality);
        if (locality.isNotEmpty) fullParts.add(locality.startsWith('Kec') ? locality : 'Kec. $locality');
        if (subAdmin.isNotEmpty) fullParts.add(subAdmin);
        if (admin.isNotEmpty) {
          fullParts.add(postal.isNotEmpty ? '$admin $postal' : admin);
        }
        if (country.isNotEmpty) fullParts.add(country);

        final fullAddress = fullParts.isNotEmpty ? fullParts.join(', ') : districtProvince;

        return {
          'readableName': readableName,
          'districtProvince': districtProvince,
          'fullAddress': fullAddress,
        };
      }
    } catch (_) {}

    return {
      'readableName': defaultLocationName,
      'districtProvince': defaultDistrictProvince,
      'fullAddress': defaultFullAddress,
    };
  }

  /// Reverse geocodes coordinates to simple string (backward compatibility)
  static Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final details = await getDetailedAddress(latitude: latitude, longitude: longitude);
    return details['readableName'] ?? defaultLocationName;
  }
}
