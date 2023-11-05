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

  final DBController db = DBController.getInstance();
  final ColorController cc = ColorController.getInstance();

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
    var tasks = db.getTasksForDay(now);
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
      _indicatorType = _getIndicatorType(now);
      _starsOpacity = _getStarsOpacity(now);
    });
  }

  double _getStarsOpacity(DateTime now) {
    var so = 0.0;
    if (now.hour >= 20 && now.hour < 22) {
      so = (now.hour - 20) / 2;
    } else if (now.hour >= 5 && now.hour < 7) {
      so = 1 - (now.hour - 4) / 2;
    } else if (now.hour >= 22 || now.hour < 5) {
      so = 1.0;
    } else {
      so = 0.0;
    }
    return so;
  }

  IndicatorType _getIndicatorType(DateTime now) {
    if (now.hour >= 5 && now.hour < 22) {
      return IndicatorType.sun;
    } else {
      return IndicatorType.moon;
    }
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
