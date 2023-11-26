import 'dart:ui';

import 'package:daily_planner/models/task.dart';

class Utils {
  static Color interpolateColor(Color startColor, Color endColor, double t) {
    // Ensure t is within the [0, 1] range
    t = t.clamp(0.0, 1.0);

    // Extract the red, green, and blue components of the start and end colors
    final startRed = startColor.red;
    final startGreen = startColor.green;
    final startBlue = startColor.blue;
    final endRed = endColor.red;
    final endGreen = endColor.green;
    final endBlue = endColor.blue;

    // Calculate the interpolated color
    final interpolatedColor = Color.fromARGB(
      (startColor.alpha + (endColor.alpha - startColor.alpha) * t).round(),
      (startRed + (endRed - startRed) * t).round(),
      (startGreen + (endGreen - startGreen) * t).round(),
      (startBlue + (endBlue - startBlue) * t).round(),
    );

    return interpolatedColor;
  }

  static List<double> calculateOffsetsFromTasks(List<Task> tasks) {
    List<double> offsets = [];
    for (var element in tasks) {
      var offset = getObjectPosition(element.dateTime);
      offsets.add(offset);
    }
    return offsets;
  }

  static double getObjectPosition(DateTime now) {
    var op = 0.0;
    // minutes from the start of the day
    final int minutes = now.hour * 60 + now.minute;
    if (minutes > 5 * 60) {
      op = (minutes - 300) / 1140 * 0.9;
    } else {
      op = (minutes / 300) * 0.1 + 0.9;
    }
    return op;
  }

  static int translateToHour(double t) {
    int hour;
    if (t < 0.9) {
      hour = (t / 0.9 * 19).toInt() + 5;
    } else {
      hour = ((t - 0.9) / 0.1 * 5).toInt();
    }
    // print("$t : $hour");
    return hour;
  }
}
