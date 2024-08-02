import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MotionDetectionPage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  MotionDetectionPage({required this.flutterLocalNotificationsPlugin});

  @override
  _MotionDetectionPageState createState() => _MotionDetectionPageState();
}

class _MotionDetectionPageState extends State<MotionDetectionPage> {
  List<double>? _accelerometerValues;
  final List<_ChartData> _accelerometerData = <_ChartData>[];
  int _counter = 0;
  Timer? _debounce;
  DateTime? _lastNotification;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (DateTime.now().difference(_lastUpdate).inMilliseconds > 100) {
        // Throttle sensor updates
        setState(() {
          _accelerometerValues = <double>[event.x, event.y, event.z];
          _accelerometerData
              .add(_ChartData(_counter++, event.x, event.y, event.z));
          if (_accelerometerData.length > 50) {
            // Limit data points
            _accelerometerData.removeAt(0);
          }
        });
        _checkForSignificantMotion(event);
        _lastUpdate = DateTime.now();
      }
    });
  }

  void _checkForSignificantMotion(AccelerometerEvent event) {
    _debounce
        ?.cancel(); // Use null-aware operator to cancel if _debounce is not null
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Debounce motion detection
      if (event.x.abs() > 5 || event.y.abs() > 5 || event.z.abs() > 5) {
        _showNotification();
      }
    });
  }

  Future<void> _showNotification() async {
    if (_lastNotification == null ||
        DateTime.now().difference(_lastNotification!).inSeconds > 60) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('motion_channel', 'Motion Notifications',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await widget.flutterLocalNotificationsPlugin.show(
        0,
        'Motion Detected',
        'Significant motion detected by the sensor.',
        platformChannelSpecifics,
        payload: 'item x',
      );
      _lastNotification = DateTime.now();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel debounce timer if it exists
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Motion Detection and Security'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Accelerometer Data:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(
                  title: AxisTitle(text: 'Time'),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Acceleration'),
                ),
                series: <LineSeries<_ChartData, int>>[
                  LineSeries<_ChartData, int>(
                    dataSource: _accelerometerData,
                    xValueMapper: (_ChartData data, _) => data.time,
                    yValueMapper: (_ChartData data, _) => data.x,
                    name: 'X-Axis',
                    color: Colors.red,
                  ),
                  LineSeries<_ChartData, int>(
                    dataSource: _accelerometerData,
                    xValueMapper: (_ChartData data, _) => data.time,
                    yValueMapper: (_ChartData data, _) => data.y,
                    name: 'Y-Axis',
                    color: Colors.green,
                  ),
                  LineSeries<_ChartData, int>(
                    dataSource: _accelerometerData,
                    xValueMapper: (_ChartData data, _) => data.time,
                    yValueMapper: (_ChartData data, _) => data.z,
                    name: 'Z-Axis',
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            Text(
              'Current Accelerometer Values: $_accelerometerValues',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.time, this.x, this.y, this.z);
  final int time;
  final double x;
  final double y;
  final double z;
}
