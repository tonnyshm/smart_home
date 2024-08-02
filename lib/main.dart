import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'light_service.dart';
import 'geofencing_service.dart';
import 'motion_detection_page.dart';
import 'geofencing_app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LightService()),
        ChangeNotifierProvider(create: (context) => GeofencingService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  MyApp() {
    final initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin),
    );
  }
}

class HomePage extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  HomePage({required this.flutterLocalNotificationsPlugin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smart Home App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GeofencingApp(),
                  ),
                );
              },
              child: Text('Geofencing'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MotionDetectionPage(
                      flutterLocalNotificationsPlugin:
                          flutterLocalNotificationsPlugin,
                    ),
                  ),
                );
              },
              child: Text('Motion Detection'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LightAutomationPage(),
                  ),
                );
              },
              child: Text('Light Automation'),
            ),
          ],
        ),
      ),
    );
  }
}

class LightAutomationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Light Automation'),
      ),
      body: Center(
        child: Consumer<LightService>(
          builder: (context, lightService, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Current Brightness: ${lightService.brightness}',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 20),
                if (lightService.isAutomationEnabled) ...[
                  Text(
                    'Ambient Light Level: ${lightService.ambientLightLevel}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Slider(
                    value: lightService.ambientLightLevel,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: lightService.ambientLightLevel.toString(),
                    onChanged: (value) {
                      lightService.updateAmbientLightLevel(value);
                    },
                  ),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await lightService.updateBrightness();
                  },
                  child: Text('Update Brightness'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    lightService.toggleAutomation();
                  },
                  child: Text(
                    lightService.isAutomationEnabled
                        ? 'Disable Automation'
                        : 'Enable Automation',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
