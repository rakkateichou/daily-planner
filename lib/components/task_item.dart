import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatefulWidget {
  const TaskItem({Key? key, required this.task, this.calendarStyle = false}) : super(key: key);


  final bool calendarStyle;
  final Task task;

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    var time = DateFormat.jm().format(widget.task.dateTime);

    if (time.length == 7 || time.length == 4) {
      time = "0$time";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 6),
      child: Row(
        children: [
          // add zero if hours less than 10
          SizedBox(
              width: 60, child: Text(time, style: MyTextStyles.taskTimeStyle.copyWith(color: widget.calendarStyle ? Colors.black : Colors.white))),
          Container(
            constraints: const BoxConstraints(minHeight: 116),
            margin: const EdgeInsets.only(left: 4),
            width: MediaQuery.of(context).size.width - 85,
            decoration: ShapeDecoration(
              color: const Color(0xCCF2F2F3),
              shadows: const [
                BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: 0)
              ],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 11),
                child: widget.task.content.isNotEmpty
                    ? Text(widget.task.content,
                        style: MyTextStyles.taskTextStyle)
                    : Text("*empty* ;)", style: MyTextStyles.taskTextStyle)),
          ),
        ],
      ),
    );
  }
}
