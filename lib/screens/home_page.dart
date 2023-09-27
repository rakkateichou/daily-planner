import 'dart:async';

import 'package:daily_planner/components/edit_new_page_layout.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/styles/text_styles.dart';
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

  late Box<Task> _taskBox;
  late List<Task> _tasks;

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
    _tasks = [];
    _updateTasks();
    super.initState();
  }

  Future<void> _updateTasks() async {
    _taskBox = await Hive.openBox<Task>('tasksBox');
    var tasksForToday = _taskBox.values.where((element) {
      return element.dateTime.isAfter(DateTime.now()) ||
          (element.dateTime.day == DateTime.now().day &&
              element.dateTime.month == DateTime.now().month &&
              element.dateTime.year == DateTime.now().year);
    }).toList();
    setState(() {
      _tasks = tasksForToday;
    });
  }

  @override
  void dispose() {
    _taskBox.close(); // Close the box when it's no longer needed
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

  Color interpolateColor(Color startColor, Color endColor, double t) {
    // Ensure t is within the [0, 1] range
    t = t.clamp(0.0, 1.0);

    // Extract the red, green, and blue components of the start and end colors
    final startRed = startColor.red;
    final startGreen = startColor.green;
    final startBlue = startColor.blue;
    final endRed = endColor.red;
    final endGreen = endColor.green;
    final endBlue = endColor.blue;

    // Calculate the interpolated color
    final interpolatedColor = Color.fromARGB(
      (startColor.alpha + (endColor.alpha - startColor.alpha) * t).round(),
      (startRed + (endRed - startRed) * t).round(),
      (startGreen + (endGreen - startGreen) * t).round(),
      (startBlue + (endBlue - startBlue) * t).round(),
    );

    return interpolatedColor;
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _toggleEditting();
        },
        backgroundColor: _currentButtonColor,
        child: _isEditing ? const Icon(Icons.check) : const Icon(Icons.add),
      ),
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
          Column(
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 41),
                child: Text(_timeString, style: MyTextStyles.homeMainStyle),
              ),
              if (!_isEditing)
                HomeLayout(
                  controller: _controller,
                  taskCount: _tasks.length,
                ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: _isEditing ? screenHeight * 0.87 : screenHeight * 0.61,
              margin: _isEditing
                  ? const EdgeInsets.only(top: 35)
                  : const EdgeInsets.only(top: 10),
              width: MediaQuery.of(context).size.width,
              decoration: const ShapeDecoration(
                color: Color(0x49F2F2F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
              ),
              child: _isEditing
                  ? const SingleChildScrollView(child: EditNewPageLayout())
                  : TaskLayout(tasks: _tasks),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeController extends ChangeNotifier {
  DateTime _now = DateTime.now();

  DateTime get now => _now;

  void updateDateTime(DateTime newDateTime) {
    _now = newDateTime;
    notifyListeners();
  }
}
