import 'package:daily_planner/components/task_item.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/material.dart';

class TaskLayout extends StatefulWidget {
  const TaskLayout({Key? key}) : super(key: key);

  @override
  State<TaskLayout> createState() => _TaskLayoutState();
}

class _TaskLayoutState extends State<TaskLayout> {
  late DBController db;
  late SelectingController sc;

  List<Task> tasks = [];

  void _listener() {
    setState(() {
      tasks = db.getTasksForToday();
    });
  }

  @override
  void initState() {
    sc = SelectingController.getInstance();
    db = DBController.getInstance()..addListener(_listener);
    tasks = db.getTasksForToday();
    super.initState();
  }

  @override
  void dispose() {
    db.removeListener(_listener);
    super.dispose();
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
            itemBuilder: (context, index) {
              return Dismissible(
                key: ValueKey<int>(tasks[index].id),
                onDismissed: (direction) => {
                  setState(() {
                    db.removeTask(tasks[index]);
                  }),
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Task deleted"),
                    action: SnackBarAction(
                      label: 'Undo',
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
        if (tasks.isEmpty)
          Positioned(
            bottom: 84,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Text(
                "Add new task?",
                textAlign: TextAlign.center,
                style: MyTextStyles.addNewTaskStyle,
              ),
            ),
          )
      ],
    );
  }
}
