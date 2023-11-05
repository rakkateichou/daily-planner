import 'package:daily_planner/components/cal_list.dart';
import 'package:daily_planner/controllers/color_controller.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();

  static const String routeName = '/calendar';
}

class _CalendarPageState extends State<CalendarPage> {
  final _colorController = ColorController.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: _colorController.primaryColor,
          title: const Text('Tasks'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          ],
        ),
        body: const CalList(type: CalListType.nextTasks));
  }
}
