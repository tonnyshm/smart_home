import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'light_service.dart';

class LightPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lightService = Provider.of<LightService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Light Level Sensing and Automation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Current Brightness: ${lightService.brightness}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text('Enable Automation'),
              value: lightService.isAutomationEnabled,
              onChanged: (value) {
                lightService.toggleAutomation();
              },
            ),
            ElevatedButton(
              onPressed: lightService.updateBrightness,
              child: Text('Update Brightness'),
            ),
          ],
        ),
      ),
    );
  }
}
