import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

class LightService extends ChangeNotifier {
  double _brightness = 0.0;
  double _ambientLightLevel = 0.0;
  bool _isAutomationEnabled = true;

  LightService() {
    init();
  }

  double get brightness => _brightness;
  double get ambientLightLevel => _ambientLightLevel;
  bool get isAutomationEnabled => _isAutomationEnabled;

  Future<void> init() async {
    _brightness = await ScreenBrightness().current;
    notifyListeners();
  }

  Future<void> updateBrightness() async {
    _brightness = await ScreenBrightness().current;
    notifyListeners();
  }

  Future<void> setBrightness(double brightness) async {
    await ScreenBrightness().setScreenBrightness(brightness);
    _brightness = brightness;
    notifyListeners();
  }

  void updateAmbientLightLevel(double newLevel) {
    if (_isAutomationEnabled) {
      _ambientLightLevel = newLevel;
      notifyListeners();
      _adjustBrightnessBasedOnAmbientLight();
    }
  }

  void toggleAutomation() {
    _isAutomationEnabled = !_isAutomationEnabled;
    notifyListeners();
  }

  void _adjustBrightnessBasedOnAmbientLight() {
    if (_isAutomationEnabled) {
      if (_ambientLightLevel < 0.3) {
        setBrightness(0.1); // Dim the screen for low light
      } else if (_ambientLightLevel < 0.7) {
        setBrightness(0.5); // Moderate brightness for medium light
      } else {
        setBrightness(1.0); // Full brightness for high light
      }
    }
  }
}
