import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/controllers/searching_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:daily_planner/screens/edit_task_page.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarAppBar extends StatefulWidget {
  const CalendarAppBar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<CalendarAppBar> createState() => _CalendarAppBarState();
}

class _CalendarAppBarState extends State<CalendarAppBar> {
  final cc = ColorController.getInstance();
  final shc = SearchingController.getInstance();
  final slc = SelectingController.getInstance();
  final db = DBController.getInstance();

  var isSelecting = false;

  void selectingListener() {
    setState(() {
      isSelecting = slc.isSelectingMode;
    });
  }

  @override
  void initState() {
    super.initState();
    slc.addListener(selectingListener);
  }

  @override
  void dispose() {
    slc.removeListener(selectingListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var selectLength = slc.selectedTasks.length;
    return AppBar(
      backgroundColor: cc.primaryColor,
      title: slc.isSelectingMode ? Text(AppLocalizations.of(context)!.selectedTasks(selectLength)) : Text(widget.title),
      // title: slc.isSelectingMode ? Text("${selectLength} item${selectLength == 1 ? '' : 's'} selected") : Text(widget.title),
      // search text field
      bottom: shc.isSearching
          ? PreferredSize(
              preferredSize: const Size.fromHeight(56.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.hintSearch,
                    hintStyle: const TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      onPressed: () {
                        shc.toggleSeaching();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 19),
                  onChanged: (value) {
                    shc.updateQuery(value);
                  },
                ),
              ),
            )
          : null,
      actions: [
        if (isSelecting) ...[
          if (slc.selectedTasks.length == 1) ...[
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, EditTaskPage.routeName,
                    arguments: slc.selectedTasks[0]);
                slc.quitSelecting();
              },
              icon: const Icon(Icons.edit),
            ),
          ],
          IconButton(
            onPressed: () {
              db.removeTasks(slc.selectedTasks);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.deletedTasks(slc.selectedTasks.length)),
                  duration: const Duration(seconds: 2),
                ),
              );
              slc.quitSelecting();
            },
            icon: const Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () {
              slc.quitSelecting();
            },
            icon: const Icon(Icons.close),
          ),
        ],
        IconButton(
            onPressed: () {
              shc.toggleSeaching();
            },
            icon: const Icon(Icons.search)),
      ],
    );
  }
}
