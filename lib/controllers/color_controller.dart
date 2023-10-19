import 'dart:async';
import 'dart:ui';

import 'package:daily_planner/controllers/timer_controller.dart';
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

  static ColorController? _instance;

  late Timer timer;

  ColorController._();

  factory ColorController.getInstance() {
    _instance ??= ColorController._();
    return _instance!;
  }

  Future<void> initialize() async {
    calculateColor();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => calculateColor());
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

  void calculateColor() {
    var now = DateTime.now();
    var cc = Colors.white;
    var cbc = Colors.white;
    var interpolateColor = Utils.interpolateColor;
    if (now.hour >= 6 && now.hour < 12) {
      cc = interpolateColor(morningColor, dayColor, now.hour / 12);
      cbc = interpolateColor(morningButtonColor, dayButtonColor, now.hour / 12);
    } else if (now.hour >= 12 && now.hour < 17) {
      cc = dayColor;
      cbc = dayColor;
    } else if (now.hour >= 17 && now.hour < 19) {
      cc = interpolateColor(dayColor, eveningColor, now.hour / 20);
      cbc = interpolateColor(dayButtonColor, eveningButtonColor, now.hour / 20);
    } else if (now.hour >= 19 && now.hour < 21) {
      cc = eveningColor;
      cbc = eveningButtonColor;
    } else if (now.hour >= 21 && now.hour < 24) {
      cc = interpolateColor(eveningColor, nightColor, now.hour / 24);
      cbc =
          interpolateColor(eveningButtonColor, nightButtonColor, now.hour / 24);
    } else if (now.hour >= 0 && now.hour < 5) {
      cc = nightColor;
      cbc = nightButtonColor;
    } else {
      cc = interpolateColor(nightColor, morningColor, now.hour / 6);
      cbc =
          interpolateColor(nightButtonColor, morningButtonColor, now.hour / 6);
    }

    setPrimaryColor(cc);
    setSecondaryColor(cbc);
  }
}
