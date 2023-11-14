import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/controllers/searching_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:daily_planner/screens/edit_task_page.dart';
import 'package:flutter/material.dart';

class CalendarAppBar extends StatefulWidget {
  CalendarAppBar({
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
      title: slc.isSelectingMode ? Text("${selectLength} item${selectLength == 1 ? '' : 's'} selected") : Text(widget.title),
      // search text field
      bottom: shc.isSearching
          ? PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.white),
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
                  style: const TextStyle(color: Colors.white),
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
                      "${slc.selectedTasks.length} task${slc.selectedTasks.length > 1 ? "s" : ""} deleted"),
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
