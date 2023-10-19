import 'package:daily_planner/components/cal_item_header.dart';
import 'package:daily_planner/components/task_item.dart';
import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/screens/calendar_last_tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();

  static const String routeName = '/calendar';
}

class _CalendarPageState extends State<CalendarPage> {
  final _db = DBController.getInstance();
  final _colorController = ColorController.getInstance();

  List<Widget> generateNextPage(int page) {
    final tasks = _db.getNextNTasksFromToday(10, page);
    final widgets = <Widget>[];
    
    for (var i = 0; i < tasks.length; i++) {
      if (i == 0 || tasks[i].dateTime.day != tasks[i - 1].dateTime.day) {
        widgets.add(CalItemHeader(date: DateFormat.yMMMMd().format(tasks[i].dateTime)));
      }
      widgets.add(TaskItem(task: tasks[i], calendarStyle: true));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _db.getNextNTasksFromToday(1, 1);
    final widgets = generateNextPage(1);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _colorController.primaryColor,
        title: Text('Tasks'),
      ),
      body: ListView.builder(
          itemCount: widgets.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  onTap: () {
                    Navigator.pushNamed(
                        context, CalendarLastTasksPage.routeName);
                  },
                  title: const Text('Past tasks'),
                ),
              );
            } else {
              return widgets[index - 1];
            }
          }),
    );
  }
}
