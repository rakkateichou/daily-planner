import 'dart:async';

import 'package:daily_planner/components/colorful_background.dart';
import 'package:daily_planner/components/edit_new_page_layout.dart';
import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/screens/calendar_page.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/home_layout.dart';
import '../components/task_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _timeString;
  
  late ColorController _colorController;

  bool _isEditing = false;

  late Task _lastTaskSaved;

  late DBController db;

  late DateTime now;

  @override
  void initState() {
    _colorController = ColorController.getInstance();
    db = DBController.getInstance();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _tick());
    now = DateTime.now();
    _timeString = _formatDateTime(now);

    // change _now so whole day passes in 10 seconds
    // Timer.periodic(const Duration(milliseconds: 500), (timer) {
    //   setState(() {
    //     _now = _now.add(const Duration(minutes: 1));
    //     _calculateTimeVariables();
    //   });
    // });
    _lastTaskSaved =
        Task(id: 0, content: "Dummy Task", dateTime: DateTime.now());
    super.initState();
  }

  void _toggleEditting() {
    setState(() {
      _isEditing = !_isEditing;
    });
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isEditing) {
            db.addTask(_lastTaskSaved);
          }
          _toggleEditting();
        },
        backgroundColor: _colorController.secondaryColor,
        child: _isEditing ? const Icon(Icons.check) : const Icon(Icons.add),
      ),
      appBar: MediaQuery.of(context).viewInsets.bottom < 100
          ? AppBar(
              toolbarHeight: 83,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(_timeString, style: MyTextStyles.homeMainStyle),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, CalendarPage.routeName);
                  },
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            )
          : null,
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: _isEditing
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
      body: Stack(
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
                  ? (screenHeight - MediaQuery.of(context).viewInsets.bottom) *
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
                        popCallback: () => _toggleEditting(),
                      ))
                  : const TaskLayout(),
            ),
          ),
        ],
      ),
    );
  }
}
