import 'dart:async';

import 'package:daily_planner/components/sun_moon_indicator.dart';
import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/navigator_service.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:daily_planner/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with RouteAware {
  late String _tasksString;
  late double _objectPosition;

  late VoidCallback _update;
  late Timer timer;

  DBController db = DBController.getInstance();
  ColorController cc = ColorController.getInstance();

  @override
  void initState() {
    super.initState();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    NavigatorService.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPushNext() {
    timer.cancel();
    super.didPushNext();
  }

  @override
  void didPopNext() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _update());
    super.didPopNext();
  }

  @override
  void dispose() {
    NavigatorService.routeObserver.unsubscribe(this);
    timer.cancel();
    super.dispose();
  }

  void setTasksStatus(DateTime now) {
    var tasks = db.getTasksForToday();
    var currentContext = NavigatorService.navigatorKey.currentContext!;
    setState(() {
      if (tasks.isEmpty) {
        _tasksString = AppLocalizations.of(currentContext)!.tasksStringComplete;
      } else if (tasks.length == 1) {
        _tasksString = AppLocalizations.of(currentContext)!.tasksStringOne;
      } else {
        _tasksString =
            AppLocalizations.of(currentContext)!.tasksStringIncomplete(tasks.length);
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
