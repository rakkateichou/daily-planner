import 'package:daily_planner/controllers/color_controller.dart';
import 'package:flutter/material.dart';

class CalendarLastTasksPage extends StatefulWidget {
  const CalendarLastTasksPage({super.key});

  static String routeName = '/calendar/last_tasks';

  @override
  State<CalendarLastTasksPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarLastTasksPage> {

  final _colorController = ColorController.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _colorController.primaryColor,
        title: const Text('Past Tasks'),
      ),
      body: ListView.builder(itemBuilder: (context, index) {
        return null;
      }),
    );
  }
}