import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatefulWidget {
  const TaskItem({Key? key, required this.task}) : super(key: key);

  final Task task;

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    
    var time = DateFormat.jm().format(widget.task.dateTime);

    return Container(
      height: 116,
      margin: const EdgeInsets.only(bottom: 20, left: 6),
      child: Row(
        children: [
          Text(time, style: MyTextStyles.taskTimeStyle),
          Container(
            margin: const EdgeInsets.only(left: 4),
            width: MediaQuery.of(context).size.width - 85,
            height: 116,
            decoration: ShapeDecoration(
              color: Color(0xCCF2F2F3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 11),
              child: Text("Task 1", style: MyTextStyles.taskTextStyle),
            ),
          )
        ],
      ),
    );
  }
}
