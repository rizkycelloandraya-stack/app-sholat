import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PermissionUtils {
  /// Check and request location permissions safely
  static Future<bool> ensureLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Request local notification permission on Android 13+ and iOS
  static Future<bool> requestNotificationPermissions(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted =
            await androidPlugin?.requestNotificationsPermission() ?? false;
        return granted;
      } else if (Platform.isIOS) {
        final iosPlugin = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
        return granted;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
