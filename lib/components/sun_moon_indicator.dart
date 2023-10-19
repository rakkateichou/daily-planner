import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intl;

class SunMoonIndicator extends StatefulWidget {
  const SunMoonIndicator(
      {Key? key,
      required this.position,
      this.indicatorType = IndicatorType.sun,
      this.starsOpacity = 0.0,
      this.tasks = const [],
      this.cloudAppearance = const (0.3, 0.5)})
      : super(key: key);

  final double position;
  final IndicatorType indicatorType;
  final double starsOpacity;
  final List<double> tasks;
  final (double, double) cloudAppearance;

  @override
  _SunMoonIndicatorState createState() => _SunMoonIndicatorState();
}

class _SunMoonIndicatorState extends State<SunMoonIndicator> {
  PictureInfo? moonDotsPI;
  PictureInfo? starsPI;
  PictureInfo? cloudPI;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  _loadSvg() async {
    var mpi = await vg.loadPicture(const SvgAssetLoader('assets/moon_dots.svg'),
        null); // TODO: make it native maybe ?
    var spi =
        await vg.loadPicture(const SvgAssetLoader('assets/stars.svg'), null);
    // var cpi = await vg.loadPicture(const SvgAssetLoader('assets/cloud.svg'), null);
    setState(() {
      moonDotsPI = mpi;
      starsPI = spi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: CustomPaint(
      painter: CurvePainter(widget.position, widget.indicatorType,
          widget.starsOpacity, widget.tasks, moonDotsPI, starsPI),
      size: Size(MediaQuery.of(context).size.width, 220),
    ));
  }
}

class CurvePainter extends CustomPainter {
  final double t; // Add a t parameter
  final IndicatorType indicatorType;
  final PictureInfo? moonDotsPI;
  final PictureInfo? starsPI;
  final double starsOpacity;
  final List<double> tasks;
  final dateTime = DateTime(1970, 0, 0, 0, 0);

  CurvePainter(this.t, this.indicatorType, this.starsOpacity, this.tasks,
      this.moonDotsPI, this.starsPI);

  @override
  void paint(Canvas canvas, Size size) {
    // Define paint properties for the curve
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Create a path for the curve
    final path = Path();

    // Calculate control points and curve points
    final double controlPointX = size.width / 2;
    final double controlPointY = size.height - 150.0;
    final double endPointX = size.width;
    final double endPointY = size.height;

    final startPoint = Offset(0, size.height);
    final controlPoint = Offset(controlPointX, controlPointY);
    final endPoint = Offset(endPointX, endPointY);

    // Move the path to the starting point
    path.moveTo(startPoint.dx, startPoint.dy);

    // Add a quadratic Bezier curve to the path
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    // Draw the path on the canvas
    canvas.drawPath(path, paint);

    // Calculate the position of the circle on the curve
    final circleX = (1 - t) * (1 - t) * startPoint.dx +
        2 * (1 - t) * t * controlPoint.dx +
        t * t * endPoint.dx;
    final circleY = (1 - t) * (1 - t) * startPoint.dy +
        2 * (1 - t) * t * controlPoint.dy +
        t * t * endPoint.dy;

    // draw dilimeter
    final t2 = 0.9;

    final circleX2 = (1 - t2) * (1 - t2) * startPoint.dx +
        2 * (1 - t2) * t2 * controlPoint.dx +
        t2 * t2 * endPoint.dx;
    final circleY2 = (1 - t2) * (1 - t2) * startPoint.dy +
        2 * (1 - t2) * t2 * controlPoint.dy +
        t2 * t2 * endPoint.dy;

    canvas.drawLine(Offset(circleX2 + 3, circleY2 - 4),
        Offset(circleX2 + 8, circleY2 - 13), paint);

    // draw 12:00 (a. m.) text above the dilimeter
    final textPainter = TextPainter(
        text: TextSpan(
            text: intl.DateFormat.jm().format(dateTime),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(circleX2 + 10 - textPainter.width / 2,
            circleY2 - 15 - textPainter.height));

    // Draw the moving circle
    final circlePaint = Paint()
      ..color = indicatorType == IndicatorType.sun
          ? const Color(0xFFFFB359)
          : const Color(0xFFB0B0AF);

    // Apply a blur effect to the circle
    final blurSigma = 1.0;
    final blurFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    circlePaint.maskFilter = blurFilter;

    canvas.drawCircle(Offset(circleX, circleY), 35.0, circlePaint);

    // Calculate positions of task dots
    final taskDots = <Offset>[];
    for (var i = 0; i < tasks.length; i++) {
      final taskX = (1 - tasks[i]) * (1 - tasks[i]) * startPoint.dx +
          2 * (1 - tasks[i]) * tasks[i] * controlPoint.dx +
          tasks[i] * tasks[i] * endPoint.dx;
      final taskY = (1 - tasks[i]) * (1 - tasks[i]) * startPoint.dy +
          2 * (1 - tasks[i]) * tasks[i] * controlPoint.dy +
          tasks[i] * tasks[i] * endPoint.dy;
      taskDots.add(Offset(taskX, taskY));
    }

    // Draw task dots
    final taskPaint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < taskDots.length; i++) {
      taskPaint.color = taskDots[i].dx > circleX
          ? const Color(0xFFFFB359)
          : const Color(0xFFB0B0AF);
      canvas.drawCircle(taskDots[i], 5.0, taskPaint);
    }

    if (indicatorType == IndicatorType.moon && moonDotsPI != null) {
      canvas.drawImage(moonDotsPI!.picture.toImageSync(50, 50),
          Offset(circleX - 20, circleY - 20), paint);
    }
    if (starsOpacity > 0 && starsPI != null) {
      canvas.drawPicture(starsPI!.picture);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

enum IndicatorType { sun, moon }
