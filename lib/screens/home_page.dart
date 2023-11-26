import 'dart:async';

import 'package:daily_planner/components/colorful_background.dart';
import 'package:daily_planner/components/edit_new_page_layout.dart';
import 'package:daily_planner/components/my_appbar.dart';
import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/controllers/editing_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/navigator_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/home_layout.dart';
import '../components/task_layout.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late String _timeString;

  bool _isEditing = false;

  late Task _lastTaskSaved;

  ColorController cc = ColorController.getInstance();
  DBController db = DBController.getInstance();
  SelectingController sc = SelectingController.getInstance();
  late EditingController ec;

  late DateTime now;
  late Timer timer;

  @override
  void initState() {
    ec = EditingController.getInstance()
      ..addListener(() {
        setState(() {
          _isEditing = ec.isEditing;
        });
      });
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _tick());
    now = DateTime.now();
    _timeString = _formatDateTime(now);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NavigatorService.routeObserver.subscribe(this, ModalRoute.of(context)!);
    _lastTaskSaved = Task(
        id: 0,
        content: AppLocalizations.of(context)!.emptyTaskContent,
        dateTime: DateTime.now());
  }

  @override
  void dispose() {
    timer.cancel();
    NavigatorService.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    timer.cancel();
    cc.freezeTime();
    super.didPushNext();
  }

  @override
  void didPopNext() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _tick());
    cc.unfreezeTime();
    super.didPopNext();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  void _tick() {
    setState(() {
      now = DateTime.now();
      _timeString = _formatDateTime(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: ListenableBuilder(
        listenable: cc,
        builder: (child, context) => FloatingActionButton(
          onPressed: () {
            if (sc.isSelectingMode) {
              sc.quitSelecting();
            }
            if (_isEditing) {
              db.addTask(_lastTaskSaved);
            }
            ec.toggleEditing();
          },
          backgroundColor: cc.secondaryColor,
          child: _isEditing ? const Icon(Icons.check) : const Icon(Icons.add),
        ),
      ),
      appBar: MyAppBar(
        timeString: _timeString,
      ),
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: _isEditing
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
      body: WillPopScope(
        onWillPop: () async {
          if (sc.isSelectingMode) {
            sc.quitSelecting();
            return false;
          }
          return true;
        },
        child: Stack(
          children: [
            ColorfulBackground(),
            Stack(
              children: [
                if (!_isEditing) const HomeLayout(),
              ],
            ),
            Positioned(
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: _isEditing
                    ? (screenHeight -
                            MediaQuery.of(context).viewInsets.bottom) *
                        0.87
                    : screenHeight * 0.61,
                margin: _isEditing
                    ? const EdgeInsets.only(top: 35)
                    : const EdgeInsets.only(top: 10),
                width: MediaQuery.of(context).size.width,
                decoration: const ShapeDecoration(
                  color: Color.fromRGBO(242, 242, 243, 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                ),
                child: _isEditing
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 56 + 25),
                        reverse: true,
                        child: EditNewPageLayout(
                          taskCallback: (task) {
                            _lastTaskSaved = task;
                          },
                          taskToEdit: ec.taskToEdit,
                          popCallback: () => ec.toggleEditing(),
                        ))
                    : const TaskLayout(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
