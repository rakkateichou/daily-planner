import 'package:daily_planner/components/task_item.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/navigator_service.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TaskLayout extends StatefulWidget {
  const TaskLayout({Key? key}) : super(key: key);

  @override
  State<TaskLayout> createState() => _TaskLayoutState();
}

class _TaskLayoutState extends State<TaskLayout> with RouteAware {
  late DBController db;
  late SelectingController sc;

  List<Task> tasks = [];

  var noTasksColor = const Color(0x00d9d9d9).withOpacity(0.3);

  void _listener() {
    try {
      setState(() {
        tasks = db.todayTasks;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    sc = SelectingController.getInstance();
    db = DBController.getInstance()..addListener(_listener);
    tasks = db.getTasksForToday();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    NavigatorService.routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    NavigatorService.routeObserver.unsubscribe(this);
    db.removeListener(_listener);
    super.dispose();
  }

  @override
  void didPushNext() {
    db.removeListener(_listener);
    super.didPushNext();
  }

  @override
  void didPopNext() {
    db.addListener(_listener);
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: ListView.builder(
            itemCount: tasks.length,
            padding: const EdgeInsets.only(bottom: 64, top: 20),
            itemBuilder: (itemContext, index) {
              return Dismissible(
                key: ValueKey<int>(tasks[index].id),
                onDismissed: (direction) => {
                  db.removeTask(tasks[index]),
                  tasks.removeAt(index),
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.taskDeleted),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)!.undo,
                      onPressed: () {
                        setState(() {
                          db.restoreLastDeleteTask();
                        });
                      },
                    ),
                  ))
                },
                child: ListenableBuilder(
                  listenable: sc,
                  builder: (context, child) => TaskItem(
                    task: tasks[index],
                    isSelected: sc.checkSelected(tasks[index]),
                    onTap: () => sc.onTap(tasks[index]),
                    onLongPress: () => sc.onLongPress(tasks[index]),
                  ),
                ),
              );
            },
          ),
        ),
        if (tasks.isEmpty) ...[
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 150),
              child: Column(
                children: [
                  SvgPicture.asset('assets/cloud.svg',
                      width: 100,
                      height: 50,
                      colorFilter:
                          ColorFilter.mode(noTasksColor, BlendMode.srcIn)),
                  Text(AppLocalizations.of(context)!.noTasks,
                      style: MyTextStyles.addNewTaskStyle
                          .copyWith(color: noTasksColor))
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 84,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text(
                AppLocalizations.of(context)!.addNewTaskQ,
                textAlign: TextAlign.center,
                style: MyTextStyles.addNewTaskStyle,
              ),
            ),
          )
        ]
      ],
    );
  }
}
