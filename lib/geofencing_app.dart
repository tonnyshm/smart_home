import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'geofencing_service.dart';

class GeofencingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final geofencingService = Provider.of<GeofencingService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Geofencing App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Geofencing Status:'),
            Text(geofencingService.currentStatus ?? 'Unknown'),
            ElevatedButton(
              onPressed: geofencingService.startGeofencing,
              child: Text('Start Geofencing'),
            ),
          ],
        ),
      ),
    );
  }
}
