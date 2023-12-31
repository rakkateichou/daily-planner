import 'package:daily_planner/components/cal_item_header.dart';
import 'package:daily_planner/components/task_item.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/controllers/searching_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/screens/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cal_list_type.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalList extends StatefulWidget {
  const CalList({Key? key, required this.type}) : super(key: key);

  final CalListType type;

  @override
  CalListState createState() => CalListState();
}

class CalListState extends State<CalList> {
  static const pageLength = 10;

  final db = DBController.getInstance();
  final selectc = SelectingController.getInstance();
  final searchc = SearchingController.getInstance();

  late ScrollController scrollController;

  bool isLoading = false;
  List<Task> tasks = [];
  int page = 0;

  late int itemCount;
  late List<Widget> widgets;

  void _searchListener() {
    scrollController.jumpTo(0);
    tasks = [];
    page = 0;
    widgets = generateNextPage();
  }

  void _dbListener() {
    tasks = [];
    page = 0;
    widgets = generateNextPage();
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (isLoading) return;
      if (tasks.length < 10) return;
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      if (maxScroll - currentScroll <= 200) {
        widgets.addAll(generateNextPage());
      }
    });
    searchc.addListener(_searchListener);
    db.addListener(_dbListener);
    widgets = generateNextPage();
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchc.removeListener(_searchListener);
    db.removeListener(_dbListener);
    super.dispose();
  }

  List<Widget> generateNextPage() {
    if (isLoading) return [];
    setState(() => isLoading = true);

    var tasksToAdd = <Task>[];
    if (widget.type == CalListType.lastTasks) {
      tasksToAdd = db.getPastTasks(pageLength, page, search: searchc.query);
    } else if (widget.type == CalListType.nextTasks) {
      tasksToAdd = db.getNextTasks(pageLength, page, search: searchc.query);
    }
    tasks.addAll(tasksToAdd);

    final widgets = <Widget>[];
    for (var i = 0; i < tasksToAdd.length; i++) {
      var cip = page * pageLength + i; // current item position
      if (i == 0 || tasks[cip].dateTime.day != tasks[cip - 1].dateTime.day) {
        widgets.add(CalItemHeader(
            date: DateFormat.yMMMMd().format(tasks[cip].dateTime)));
      }
      widgets.add(
        ListenableBuilder(
          listenable: selectc,
          builder: (context, child) => TaskItem(
            task: tasks[i],
            calendarStyle: true,
            isSelected: selectc.checkSelected(tasks[i]),
            onTap: () => selectc.onTap(tasks[i]),
            onLongPress: () => selectc.onLongPress(tasks[i]),
          ),
        ),
      );
    }

    setState(() => isLoading = false);

    page++;

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
            Navigator.pushNamed(context, CalendarPage.routeName,
                arguments: CalListType.lastTasks);
          },
          title: Text(AppLocalizations.of(context)!.pastTasksTitle),
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
    Widget topWidget = const SizedBox(); 
    if (widgets.isEmpty) {
      topWidget = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(height: 10),
          if (searchc.isSearching)
            Text(AppLocalizations.of(context)!.noTasksFound)
          else
            Text(AppLocalizations.of(context)!.noTasks),
        ],
      ));
    }
    if (widget.type == CalListType.nextTasks) {
      itemCount = isLoading ? widgets.length + 2 : widgets.length + 1;
    } else if (widget.type == CalListType.lastTasks) {
      itemCount = isLoading ? widgets.length + 1 : widgets.length;
    }
    return Stack(
      children: [
        topWidget,
        Scrollbar(
          child: ListView.builder(
            controller: scrollController,
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
        ),
      ],
    );
  }
}
