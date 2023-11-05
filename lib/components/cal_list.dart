import 'package:daily_planner/components/cal_item_header.dart';
import 'package:daily_planner/components/task_item.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/screens/calendar_last_tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalList extends StatefulWidget {
  const CalList({Key? key, required this.type}) : super(key: key);

  final CalListType type;

  @override
  _CalListState createState() => _CalListState();
}

class _CalListState extends State<CalList> {
  DBController db = DBController.getInstance();
  SelectingController sc = SelectingController.getInstance();

  late ScrollController _scrollController;

  bool isLoading = false;
  List<Task> tasks = [];
  int page = 0;

  late int itemCount;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (isLoading) return;
      if (tasks.length < 10) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 200) {
        generateNextPage();
      }
    });
  }

  List<Widget> generateNextPage() {
    setState(() => isLoading = true);
    if (widget.type == CalListType.lastTasks) {
      tasks.addAll(db.getNextNTasksBeforeToday(10, page));
    } else if (widget.type == CalListType.nextTasks) {
      tasks.addAll(db.getNextNTasksFromToday(10, page));
    }
    setState(() {
      page++;
    });
    final widgets = <Widget>[];

    for (var i = 0; i < tasks.length; i++) {
      if (i == 0 || tasks[i].dateTime.day != tasks[i - 1].dateTime.day) {
        widgets.add(
            CalItemHeader(date: DateFormat.yMMMMd().format(tasks[i].dateTime)));
      }
      widgets.add(
        GestureDetector(
          onLongPress: () => sc.onLongPress(tasks[i]),
          onTap: () => sc.onTap(tasks[i]),
          child: ListenableBuilder(
            listenable: sc,
            builder: (context, child) => TaskItem(
              task: tasks[i],
              calendarStyle: true,
              isSelected: sc.checkSelected(tasks[i]),
            ),
          ),
        ),
      );
    }

    setState(() => isLoading = false);
    return widgets;
  }

  Widget nextTaskBuilder(
      BuildContext context, List<Widget> widgets, int index) {
    if (index == 0) {
      return Card(
        elevation: 2,
        child: ListTile(
          leading: const Icon(Icons.access_time),
          onTap: () {
            Navigator.pushNamed(context, CalendarLastTasksPage.routeName);
          },
          title: const Text('Past tasks'),
        ),
      );
    } else if (index < widgets.length + 2) {
      return widgets[index - 1];
    } else {
      return const SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget lastTaskBuilder(
      BuildContext context, List<Widget> widgets, int index) {
    if (index < widgets.length + 1) {
      return widgets[index];
    } else {
      return const SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgets = generateNextPage();
    if (widget.type == CalListType.nextTasks) {
      itemCount = isLoading ? widgets.length + 2 : widgets.length + 1;
    } else if (widget.type == CalListType.lastTasks) {
      itemCount = isLoading ? widgets.length + 1 : widgets.length;
    }
    return Scrollbar(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (widget.type == CalListType.nextTasks) {
            return nextTaskBuilder(context, widgets, index);
          } else if (widget.type == CalListType.lastTasks) {
            return lastTaskBuilder(context, widgets, index);
          } else {
            // should never happen
            return const SizedBox();
          }
        },
      ),
    );
  }
}

enum CalListType { lastTasks, nextTasks }
