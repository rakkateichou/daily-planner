import 'dart:async';

import 'package:daily_planner/components/edit_new_page_layout.dart';
import 'package:daily_planner/models/calendar_arguments.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:daily_planner/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../components/home_layout.dart';
import '../components/task_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final morningColor = const Color.fromARGB(255, 161, 244, 247);
  final dayColor = const Color.fromARGB(255, 89, 153, 157);
  final eveningColor = const Color.fromARGB(255, 1, 56, 73);
  final nightColor = const Color.fromRGBO(30, 30, 30, 1);

  final morningButtonColor = const Color.fromARGB(255, 255, 179, 89);
  final dayButtonColor = const Color.fromARGB(255, 89, 153, 157);
  final eveningButtonColor = const Color.fromARGB(255, 1, 56, 73);
  final nightButtonColor = const Color.fromRGBO(30, 30, 30, 1);

  late Color _currentColor;
  late Color _currentButtonColor;

  late String _timeString;

  late HomeController _controller;

  bool _isEditing = false;

  late Task _lastTaskSaved;

  @override
  void initState() {
    _controller = HomeController();
    _calculateTimeVariables();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _tick());
    _timeString = _formatDateTime(_controller.now);
    // change _now so whole day passes in 10 seconds
    // Timer.periodic(const Duration(milliseconds: 500), (timer) {
    //   setState(() {
    //     _now = _now.add(const Duration(minutes: 1));
    //     _calculateTimeVariables();
    //   });
    // });
    _controller.fetchTasks();
    _lastTaskSaved =
        Task(id: 0, content: "Dummy Task", dateTime: DateTime.now());
    super.initState();
  }

  @override
  void dispose() {
    _controller._taskBox.close(); // Close the box when it's no longer needed
    super.dispose();
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
    _controller.updateDateTime(_controller.now.add(const Duration(seconds: 1)));
    _calculateTimeVariables();
  }

  void _calculateTimeVariables() {
    // calculate gradient color
    var now = _controller.now;
    var cc = Colors.white;
    var cbc = Colors.white;
    var interpolateColor = Utils.interpolateColor;
    if (now.hour >= 6 && now.hour < 12) {
      cc = interpolateColor(morningColor, dayColor, now.hour / 12);
      cbc = interpolateColor(morningButtonColor, dayButtonColor, now.hour / 12);
    } else if (now.hour >= 12 && now.hour < 17) {
      cc = dayColor;
      cbc = dayColor;
    } else if (now.hour >= 17 && now.hour < 19) {
      cc = interpolateColor(dayColor, eveningColor, now.hour / 20);
      cbc = interpolateColor(dayButtonColor, eveningButtonColor, now.hour / 20);
    } else if (now.hour >= 19 && now.hour < 21) {
      cc = eveningColor;
      cbc = eveningButtonColor;
    } else if (now.hour >= 21 && now.hour < 24) {
      cc = interpolateColor(eveningColor, nightColor, now.hour / 24);
      cbc =
          interpolateColor(eveningButtonColor, nightButtonColor, now.hour / 24);
    } else if (now.hour >= 0 && now.hour < 5) {
      cc = nightColor;
      cbc = nightButtonColor;
    } else {
      cc = interpolateColor(nightColor, morningColor, now.hour / 6);
      cbc =
          interpolateColor(nightButtonColor, morningButtonColor, now.hour / 6);
    }

    setState(() {
      _currentColor = cc;
      _currentButtonColor = cbc;

      _timeString = _formatDateTime(_controller.now);
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isEditing) {
            _controller.addTask(_lastTaskSaved);
          }
          _toggleEditting();
        },
        backgroundColor: _currentButtonColor,
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
                    Navigator.pushNamed(context, '/calendar',
                        arguments: CalendarArguments(_currentColor));
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
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0, 0),
                end: const Alignment(0, 1),
                colors: [_currentColor, Colors.black.withOpacity(0.51)],
              ),
            ),
          ),
          Stack(
            children: [
              if (!_isEditing)
                Container(
                  child: HomeLayout(
                    controller: _controller,
                  ),
                ),
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
                  : TaskLayout(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}

// TODO: split it into time controller and task controller later
class HomeController extends ChangeNotifier {
  DateTime _now = DateTime.now();
  DateTime get now => _now;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  final Box<Task> _taskBox;
  Box<Task> get taskBox => _taskBox;

  HomeController() : _taskBox = Hive.box<Task>('tasks');

  void addTask(Task task) {
    _tasks.add(task);
    _taskBox.put(task.id, task);
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.remove(task);
    print(task.id);
    _taskBox.delete(task.id);
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    // // this is for today but only after current time
    // var tasksForToday = _taskBox.values.where((element) {
    //   return element.dateTime.isAfter(DateTime.now()) ||
    //       (element.dateTime.day == DateTime.now().day &&
    //           element.dateTime.month == DateTime.now().month &&
    //           element.dateTime.year == DateTime.now().year);
    // }).toList();

    var tasksForToday = _taskBox.values.where((element) {
      return element.dateTime.day == DateTime.now().day &&
          element.dateTime.month == DateTime.now().month &&
          element.dateTime.year == DateTime.now().year;
    }).toList();
    _tasks = tasksForToday;
    notifyListeners();
  }

  void updateDateTime(DateTime newDateTime) {
    _now = newDateTime;
    notifyListeners();
  }
}
