import 'dart:async';

import 'package:daily_planner/components/colorful_background.dart';
import 'package:daily_planner/components/edit_new_page_layout.dart';
import 'package:daily_planner/components/my_appbar.dart';
import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/controllers/editing_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:daily_planner/models/task.dart';
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

  late ColorController cc;

  bool _isEditing = false;

  late Task _lastTaskSaved;

  late DBController db;
  late SelectingController sc;
  late EditingController ec;

  late DateTime now;
  late Timer timer;

  @override
  void initState() {
    cc = ColorController.getInstance();
    db = DBController.getInstance();
    sc = SelectingController.getInstance();
    ec = EditingController.getInstance()
      ..addListener(() {
        setState(() {
          _isEditing = ec.isEditing;
        });
      });
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _tick());
    now = DateTime.now();
    _timeString = _formatDateTime(now);
    _lastTaskSaved =
        Task(id: 0, content: "Dummy Task", dateTime: DateTime.now());
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
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
          ec.toggleEditing();
        },
        backgroundColor: cc.secondaryColor,
        child: _isEditing ? const Icon(Icons.check) : const Icon(Icons.add),
      ),
      appBar: MyAppBar(
        timeString: _timeString,
      ),
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
                        popCallback: () => ec.toggleEditing(),
                      ))
                  : const TaskLayout(),
            ),
          ),
        ],
      ),
    );
  }
}
