import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/screens/calendar_last_tasks_page.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();
  
  static const String routeName = '/calendar';
}

class _CalendarPageState extends State<CalendarPage> {
  final _db = DBController.getInstance();
  final _colorController = ColorController.getInstance();

  @override
  Widget build(BuildContext context) {
    final tasks = _db.getNextNTasksFromToday(1, 1);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _colorController.primaryColor,
        title: Text('Tasks'),
      ),
      body: ListView.builder(itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.access_time),
              onTap: () {
                Navigator.pushNamed(context, CalendarLastTasksPage.routeName);
              },
              title: Text('Past tasks'),
            ),
          );
        } else {}
      }),
    );
  }
}
