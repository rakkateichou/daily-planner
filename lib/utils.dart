import 'dart:ui';

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
}