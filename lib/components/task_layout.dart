import 'package:daily_planner/components/task_item.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/material.dart';

class TaskLayout extends StatefulWidget {
  const TaskLayout({Key? key}) : super(key: key);

  @override
  State<TaskLayout> createState() => _TaskLayoutState();
}

class _TaskLayoutState extends State<TaskLayout> {
  late DBController db;

  @override
  void initState() {
    db = DBController.getInstance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tasks = db.getTasksForDay(DateTime.now());
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
                  })
                },
                child: TaskItem(task: tasks[index]),
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
