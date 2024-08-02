import 'package:flutter/material.dart';
import 'package:easy_geofencing/enums/geofence_status.dart';
import 'package:easy_geofencing/easy_geofencing.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'geofence_region.dart';

class GeofencingService with ChangeNotifier {
  String? currentStatus;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  GeofencingService() {
    final initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void startGeofencing() {
    final List<GeofenceRegion> geofenceRegions = [
      GeofenceRegion(
          id: 'home',
          latitude: -1.9742551624406302,
          longitude: 30.04082045095616,
          radius: 8),
      GeofenceRegion(
          id: 'work', latitude: -1.9479064, longitude: 30.0597852, radius: 100),
      GeofenceRegion(
          id: 'school',
          latitude: -1.9559242,
          longitude: 30.1041054,
          radius: 100),
      // Add more regions as needed
    ];

    for (var region in geofenceRegions) {
      EasyGeofencing.startGeofenceService(
        pointedLatitude: region.latitude.toString(),
        pointedLongitude: region.longitude.toString(),
        radiusMeter: region.radius.toString(),
        eventPeriodInSeconds: 3,
      );

      EasyGeofencing.getGeofenceStream()!.listen((GeofenceStatus status) {
        _handleGeofenceEvent(status, region.id);
      });
    }
  }

  void _handleGeofenceEvent(GeofenceStatus status, String id) {
    String message;
    if (status == GeofenceStatus.enter) {
      message = 'Entered $id';
    } else if (status == GeofenceStatus.exit) {
      message = 'Exited $id';
    } else {
      message = 'Unknown event for $id';
    }
    currentStatus = message;
    _showNotification(message);
    notifyListeners();
  }

  void _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'geofencing_channel',
      'Geofencing Notifications',
      channelDescription: 'Notifications for geofencing events',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Geofencing Event',
      message,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
