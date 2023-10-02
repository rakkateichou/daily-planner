import 'package:daily_planner/components/sun_moon_indicator.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/material.dart';

import '../screens/home_page.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout(
      {Key? key, required this.controller, required this.taskCount})
      : super(key: key);

  final HomeController controller;
  final int taskCount;

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late String _tasksString;
  late double _objectPosition;
  late IndicatorType _indicatorType;
  late double _starsOpacity = 0.0;

  late VoidCallback _listener;

  @override
  void initState() {
    _listener = () {
      readController();
    };
    widget.controller.addListener(_listener);
    readController();
    _tasksString = "";
    setTasksStatus();

    // _tasksString = "Counting your to-do's for today";

    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  void setTasksStatus() {
    setState(() {
      if (widget.taskCount == 0) {
        _tasksString = "You completed all tasks today";
      } else if (widget.taskCount == 1) {
        _tasksString = "You have 1 to-do for today";
      } else {
        _tasksString = "You have ${widget.taskCount} to-do's for today";
      }
    });
  }

  void readController() {
    var now = widget.controller.now;
    setState(() {
      _objectPosition = _getObjectPosition(now);
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

  double _getObjectPosition(DateTime now) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: SunMoonIndicator(
            position: _objectPosition,
            indicatorType: _indicatorType,
            starsOpacity: _starsOpacity,
          ),
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
