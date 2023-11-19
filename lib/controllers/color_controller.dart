import 'dart:async';

import 'package:daily_planner/utils.dart';
import 'package:flutter/material.dart';

class ColorController extends ChangeNotifier {
  final morningColor = const Color.fromARGB(255, 161, 244, 247);
  final dayColor = const Color.fromARGB(255, 89, 153, 157);
  final eveningColor = const Color.fromARGB(255, 1, 56, 73);
  final nightColor = const Color.fromRGBO(30, 30, 30, 1);

  final morningButtonColor = const Color.fromARGB(255, 255, 179, 89);
  final dayButtonColor = const Color.fromARGB(255, 89, 153, 157);
  final eveningButtonColor = const Color.fromARGB(255, 1, 56, 73);
  final nightButtonColor = const Color.fromRGBO(30, 30, 30, 1);

  late Function(Timer) timerCallback;

  static ColorController? _instance;

  late Timer timer;

  ColorController._();

  factory ColorController.getInstance() {
    _instance ??= ColorController._();
    return _instance!;
  }

  Future<void> initialize() async {
    timerCallback = (Timer t) => calculateColor(DateTime.now().hour);
    calculateColor(DateTime.now().hour);
    timer = Timer.periodic(
        const Duration(seconds: 1), timerCallback);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Color _primaryColor = Colors.white;
  get primaryColor => _primaryColor;

  Color _secondaryColor = Colors.white;
  get secondaryColor => _secondaryColor;

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void setSecondaryColor(Color color) {
    _secondaryColor = color;
    notifyListeners();
  }

  void freezeTime() {
    timer.cancel();
  }

  void unfreezeTime() {
    timer.cancel();
    timer = Timer.periodic(
        const Duration(seconds: 1), timerCallback);
  }

  void manualSetColorFromT(double t) {
    var hour = Utils.translateToHour(t);
    // print(hour);
    calculateColor(hour);
  }

  void calculateColor(int hour) {
    var cc = Colors.white;
    var cbc = Colors.white;
    var interpolateColor = Utils.interpolateColor;
    if (hour >= 6 && hour < 12) {
      cc = interpolateColor(morningColor, dayColor, hour / 12);
      cbc = interpolateColor(morningButtonColor, dayButtonColor, hour / 12);
    } else if (hour >= 12 && hour < 17) {
      cc = dayColor;
      cbc = dayColor;
    } else if (hour >= 17 && hour < 19) {
      cc = interpolateColor(dayColor, eveningColor, hour / 20);
      cbc = interpolateColor(dayButtonColor, eveningButtonColor, hour / 20);
    } else if (hour >= 19 && hour < 21) {
      cc = eveningColor;
      cbc = eveningButtonColor;
    } else if (hour >= 21 && hour < 24) {
      cc = interpolateColor(eveningColor, nightColor, hour / 24);
      cbc =
          interpolateColor(eveningButtonColor, nightButtonColor, hour / 24);
    } else if (hour >= 0 && hour < 5) {
      cc = nightColor;
      cbc = nightButtonColor;
    } else {
      cc = interpolateColor(nightColor, morningColor, hour / 6);
      cbc =
          interpolateColor(nightButtonColor, morningButtonColor, hour / 6);
    }

    setPrimaryColor(cc);
    setSecondaryColor(cbc);
  }
}
