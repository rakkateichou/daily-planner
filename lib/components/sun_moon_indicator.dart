import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intl;

class SunMoonIndicator extends StatefulWidget {
  const SunMoonIndicator(
      {Key? key,
      required this.position,
      this.tasks = const [],
      this.cloudAppearance = const (0.3, 0.5),
      this.onIndicatorPosition,
      this.onDragStart,
      this.onDragEnd})
      : super(key: key);

  final double position;
  final List<double> tasks;
  final (double, double) cloudAppearance;
  final Function(double)? onIndicatorPosition;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  @override
  SunMoonIndicatorState createState() => SunMoonIndicatorState();
}

class SunMoonIndicatorState extends State<SunMoonIndicator>
    with SingleTickerProviderStateMixin {
  PictureInfo? moonDotsPI;
  PictureInfo? starsPI;
  PictureInfo? cloudPI;

  Offset tapPosition = const Offset(0, 0);
  Offset firstTapPosition = const Offset(0, 0);
  bool isMoving = false;

  bool legitDrag = false;

  Offset initialIndicatorPosition = const Offset(0, 0);

  void legitCallback(bool legit) {
    legitDrag = legit;
  }

  void initialIndicatorPosCallback(Offset pos) {
    if (legitDrag) return;
    initialIndicatorPosition = pos;
  }

  late AnimationController animation;

  double getStarsOpacityT(double t) {
    var so = 0.0;
    // if (t >= 0.7 && t < 0.9) {
    //   so = (t - 0.7) / 0.2;
    // } else if (t >= 0.0 && t < 0.2) {
    //   so = 1 - t / 0.2;
    if (t >= 0.7 && t <= 1.0 || t >= 0.0 && t < 0.2) {
      so = 1.0;
    } else {
      so = 0.0;
    }
    return so;
  }

  double tFromTapPosition(Offset tap) {
    return tap.dx / MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    _loadSvg();
    animation = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDragEnd!();
        isMoving = false;
        animation.reset();
      }
    });
    animation.addListener(() {
      if (!legitDrag) return;
      setState(() {
        tapPosition = Offset.lerp(
            tapPosition, initialIndicatorPosition, animation.value)!;
      });
      widget.onIndicatorPosition!(tFromTapPosition(tapPosition));
    });
    super.initState();
  }

  @override
  void dispose() {
    animation.dispose();
    moonDotsPI?.picture.dispose();
    starsPI?.picture.dispose();
    super.dispose();
  }

  _loadSvg() async {
    var mpi = await vg.loadPicture(const SvgAssetLoader('assets/moon_dots.svg'),
        null); // noTODO: make it native maybe ?
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
    return GestureDetector(
      onPanUpdate: (details) {
        if (!legitDrag) return;
        setState(() {
          tapPosition = details.localPosition;
        });
        widget.onIndicatorPosition!(tFromTapPosition(tapPosition));
      },
      onPanDown: (details) => {
        if (animation.isAnimating) animation.stop(),
        setState(() {
          firstTapPosition = details.localPosition;
          tapPosition = details.localPosition;
          isMoving = true;
        }),
        widget.onDragStart!(),
      },
      onPanEnd: (details) => {
        animation.forward(from: 0.0),
        //widget.onDragEnd!()
      },
      child: CustomPaint(
        painter: CurvePainter(
            widget.position,
            getStarsOpacityT(
                legitDrag ? tFromTapPosition(tapPosition) : widget.position),
            widget.tasks,
            moonDotsPI,
            starsPI,
            tapPosition,
            firstTapPosition,
            isMoving,
            legitCallback,
            initialIndicatorPosCallback),
        size: Size(MediaQuery.of(context).size.width, 220),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final double t; // Add a t parameter
  final PictureInfo? moonDotsPI;
  final PictureInfo? starsPI;
  final double starsOpacity;
  final List<double> tasks;
  final dateTime = DateTime(1970, 0, 0, 0, 0);

  final Offset tapPosition;
  final Offset firstTapPosition;
  final bool isDraggedOrAnimated;

  final Function(bool)? legitDragCallback;
  final Function(Offset)? initialIndicatorCallback;

  CurvePainter(
      this.t,
      this.starsOpacity,
      this.tasks,
      this.moonDotsPI,
      this.starsPI,
      this.tapPosition,
      this.firstTapPosition,
      this.isDraggedOrAnimated,
      this.legitDragCallback,
      this.initialIndicatorCallback);

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

    // Draw dilimeter
    const t2 = 0.9;

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

    // Calculate the position of the circle on the curve
    final circleX = (1 - t) * (1 - t) * startPoint.dx +
        2 * (1 - t) * t * controlPoint.dx +
        t * t * endPoint.dx;
    final circleY = (1 - t) * (1 - t) * startPoint.dy +
        2 * (1 - t) * t * controlPoint.dy +
        t * t * endPoint.dy;

    var firstTapPositionCheck = isDraggedOrAnimated &&
                firstTapPosition.dx > circleX - 35 &&
                firstTapPosition.dx < circleX + 35 &&
                firstTapPosition.dy > circleY - 35 &&
                firstTapPosition.dy < circleY + 35;

    // Check if the indicator is a sun or a moon
    var indicatorType = (!firstTapPositionCheck && t >= 0.85 ||
            firstTapPositionCheck && tapPosition.dx / size.width > 0.85)
        ? IndicatorType.moon
        : IndicatorType.sun;

    // Draw the sun
    final circlePaint = Paint()
      ..color = indicatorType == IndicatorType.sun
          ? const Color(0xFFFFB359)
          : const Color(0xFFB0B0AF);

    // Apply a blur effect
    const blurSigma = 1.0;
    const blurFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    circlePaint.maskFilter = blurFilter;

    // Draw the circle on the canvas
    if (firstTapPositionCheck) {
      initialIndicatorCallback!(Offset(circleX, circleY));
      canvas.drawCircle(tapPosition, 35.0, circlePaint);
      legitDragCallback!(true);
    } else {
      canvas.drawCircle(Offset(circleX, circleY), 35.0, circlePaint);
      legitDragCallback!(false);
    }

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

    // Draw moon dots
    if (indicatorType == IndicatorType.moon && moonDotsPI != null) {
      if (firstTapPositionCheck) {
        canvas.drawImage(moonDotsPI!.picture.toImageSync(50, 50),
            Offset(tapPosition.dx - 20, tapPosition.dy - 20), paint);
      } else {
        canvas.drawImage(moonDotsPI!.picture.toImageSync(50, 50),
            Offset(circleX - 20, circleY - 20), paint);
      }
    }

    // Draw stars
    if (starsOpacity > 0 && starsPI != null) {
      canvas.drawPicture(starsPI!.picture);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum IndicatorType { sun, moon }
