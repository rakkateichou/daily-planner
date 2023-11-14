import 'dart:async';

import 'package:daily_planner/components/sun_moon_indicator.dart';
import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:daily_planner/utils.dart';
import 'package:flutter/material.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late String _tasksString;
  late double _objectPosition;
  late IndicatorType _indicatorType;
  late double _starsOpacity = 0.0;

  late VoidCallback _update;
  late Timer timer;

  DBController db = DBController.getInstance();
  ColorController cc = ColorController.getInstance();

  @override
  void initState() {
    _update = () {
      var now = DateTime.now();
      setIndicator(now);
      setTasksStatus(now);
    };
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _update());

    var now = DateTime.now();
    setIndicator(now);
    _tasksString = "";
    setTasksStatus(now);

    // _tasksString = "Counting your to-do's for today";

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void setTasksStatus(DateTime now) {
    var tasks = db.getTasksForToday();
    setState(() {
      if (tasks.isEmpty) {
        _tasksString = "You completed all tasks today";
      } else if (tasks.length == 1) {
        _tasksString = "You have 1 to-do for today";
      } else {
        _tasksString = "You have ${tasks.length} to-do's for today";
      }
    });
  }

  void setIndicator(DateTime now) {
    setState(() {
      _objectPosition = Utils.getObjectPosition(now);
      _indicatorType = Utils.getIndicatorType(now);
      _starsOpacity = Utils.getStarsOpacity(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    var db = DBController.getInstance();
    var indicatorTasks = db.getTasksForIndicator(DateTime.now());
    var tasksDoubles = Utils.calculateOffsetsFromTasks(indicatorTasks);

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.26,
          child: SunMoonIndicator(
              position: _objectPosition,
              indicatorType: _indicatorType,
              starsOpacity: _starsOpacity,
              tasks: tasksDoubles,
              draggableIndicator: true,
              onDragStart: cc.freezeTime,
              onDragEnd: cc.unfreezeTime,
              onIndicatorPosition: (position) {
                cc.manualSetColorFromT(position);
              }),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _tasksString,
            textAlign: TextAlign.center,
            style: MyTextStyles.homeMainStyle,
          ),
        )
      ],
    );
  }
}
