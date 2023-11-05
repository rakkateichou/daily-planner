
import 'package:daily_planner/controllers/color_controller.dart';
import 'package:flutter/material.dart';

class ColorfulBackground extends StatefulWidget {
  ColorfulBackground({Key? key})
      : super(key: key);

  @override
  State<ColorfulBackground> createState() => _ColorfulBackgroundState();
}

class _ColorfulBackgroundState extends State<ColorfulBackground> {

  late ColorController colorc;
  Color color = Colors.white;

  @override
  void initState() {
    colorc = ColorController.getInstance();
    colorc.addListener(() {
      // print(colorc.primaryColor);
      setState(() {
        color = colorc.primaryColor;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0, 0),
          end: const Alignment(0, 1),
          colors: [color, Colors.black.withOpacity(0.51)],
        ),
      ),
    );
  }
}