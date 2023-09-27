import 'package:daily_planner/components/task_item.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class TaskLayout extends StatefulWidget {
  const TaskLayout({Key? key, required this.tasks}) : super(key: key);

  final List<Task> tasks;

  @override
  State<TaskLayout> createState() => _TaskLayoutState();
}

class _TaskLayoutState extends State<TaskLayout> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 6,
          bottom: 0,
          child: ListView.builder(
            itemCount: widget.tasks.length,
            padding: const EdgeInsets.only(bottom: 64, top: 20),
            itemBuilder: (context, index) {
              return TaskItem(task: widget.tasks[index]);
            },
          ),
        ),
        if (widget.tasks.isEmpty)
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
