import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskItem extends StatefulWidget {
  const TaskItem(
      {Key? key,
      required this.task,
      this.calendarStyle = false,
      this.isSelected = false,
      this.onTap,
      this.onLongPress})
      : super(key: key);

  final bool calendarStyle;
  final bool isSelected;
  final Task task;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  TaskItemState createState() => TaskItemState();
}

class TaskItemState extends State<TaskItem> {
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
          SizedBox(
              width: 60,
              child: Text(time,
                  style: MyTextStyles.taskTimeStyle.copyWith(
                      color:
                          widget.calendarStyle ? Colors.black : Colors.white))),
          Container(
            constraints: const BoxConstraints(minHeight: 116),
            margin: const EdgeInsets.only(left: 4),
            width: MediaQuery.of(context).size.width - 85,
            decoration: ShapeDecoration(
              color: widget.calendarStyle
                  ? (widget.isSelected ? const Color(0xCCF2F2F3) : const Color(0xFFFFFFFF))
                  : (widget.isSelected ? const Color(0xB6E6E6E6) : const Color(0xCCF2F2F3)),
              shadows: const [
                BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: 0)
              ],
              
              shape: RoundedRectangleBorder(
                side:  widget.isSelected ? const BorderSide(color: Color(0xFF4A4A4A), width: 3) : BorderSide.none,
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                splashColor: Colors.white10,
                onTap: widget.onTap ?? () {},
                onLongPress: widget.onLongPress ?? () {},
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 11),
                    child: widget.task.content.isNotEmpty
                        ? Text(widget.task.content,
                            style: MyTextStyles.taskTextStyle)
                        : Text(AppLocalizations.of(context)!.emptyTaskContent, style: MyTextStyles.taskTextStyle)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
