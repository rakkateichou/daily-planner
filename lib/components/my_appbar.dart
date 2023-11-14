import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/controllers/editing_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:daily_planner/models/cal_list_type.dart';
import 'package:daily_planner/screens/calendar_page.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key, required this.timeString}) : super(key: key);

  final String timeString;

  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size(double.infinity, 83);
}

class _MyAppBarState extends State<MyAppBar> {
  SelectingController sc = SelectingController.getInstance();
  ColorController cc = ColorController.getInstance();
  DBController db = DBController.getInstance();
  EditingController ec = EditingController.getInstance();

  @override
  Widget build(BuildContext context) {
    AppBar? appBar;
    return ListenableBuilder(
      listenable: sc,
      builder: (context, child) {
        if (MediaQuery.of(context).viewInsets.bottom < 100) {
          if (!sc.isSelectingMode) {
            appBar = AppBar(
              toolbarHeight: 83,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(widget.timeString, style: MyTextStyles.homeMainStyle),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, CalendarPage.routeName,
                arguments: CalListType.nextTasks);
                  },
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            );
          } else {
            appBar = AppBar(
              toolbarHeight: 83,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: sc.selectedTasks.length == 1
                  ? Text(sc.selectedTasks[0].content,
                      style: MyTextStyles.homeMainStyle)
                  : Text("${sc.selectedTasks.length} Tasks Selected",
                      style: MyTextStyles.homeMainStyle),
              actions: [
                if (sc.selectedTasks.length == 1)
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      ec.startEditing(sc.selectedTasks[0]);
                      sc.quitSelecting();
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(context: context, builder:(context) => AlertDialog(
                      title: Text("Delete ${sc.selectedTasks.length} Tasks?"),
                      content: Text("Are you sure you want to delete ${sc.selectedTasks.length} tasks?"),
                      actions: [
                        TextButton(onPressed: () {
                          Navigator.pop(context);
                        }, child: Text("Cancel")),
                        TextButton(onPressed: () {
                          db.removeTasks(sc.selectedTasks);
                          sc.selectedTasks.clear();
                          sc.isSelectingMode = false;
                          Navigator.pop(context);
                        }, child: Text("Delete"))
                      ],
                    ),);
                  },
                )
              ],
            );
          }
        }
        return appBar ?? const SizedBox();
      },
    );
  }
}
