import 'dart:async';

import 'package:daily_planner/components/sun_moon_indicator.dart';
import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:daily_planner/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late String _tasksString;
  late double _objectPosition;

  late VoidCallback _update;
  late Timer timer;

  DBController db = DBController.getInstance();
  ColorController cc = ColorController.getInstance();

  @override
  void initState() {
    super.initState();
    // _tasksString = "Counting your to-do's for today";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // put it here because in initState it throws an error

    // When an inherited widget changes,
    // for example if the value of
    // Theme.of() changes, its dependent
    // widgets are rebuilt. If the
    // dependent widget's reference to
    // the inherited widget is in a
    // constructor or an initState()
    // method, then the rebuilt
    // dependent widget will not reflect
    // the changes in the inherited
    // widget.

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
        _tasksString = AppLocalizations.of(context)!.tasksStringComplete;
      } else if (tasks.length == 1) {
        _tasksString = AppLocalizations.of(context)!.tasksStringOne;
      } else {
        _tasksString =
            AppLocalizations.of(context)!.tasksStringIncomplete(tasks.length);
      }
    });
  }

  void setIndicator(DateTime now) {
    setState(() {
      _objectPosition = Utils.getObjectPosition(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    var db = DBController.getInstance();
    var indicatorTasks = db.getTasksForIndicator(DateTime.now());
    var tasksDoubles = Utils.calculateOffsetsFromTasks(indicatorTasks);

    var heightOfLayout = MediaQuery.of(context).size.height * 0.26;

    return Column(
      children: [
        SizedBox(
          height: heightOfLayout,
          child: SunMoonIndicator(
              position: _objectPosition,
              tasks: tasksDoubles,
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
