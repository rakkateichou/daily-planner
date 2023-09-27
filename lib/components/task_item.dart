import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/material.dart';

class TaskItem extends StatefulWidget {
  const TaskItem({Key? key}) : super(key: key);

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      margin: const EdgeInsets.only(bottom: 20, left: 6),
      child: Row(
        children: [
          Text("12:00pm", style: MyTextStyles.taskTimeStyle),
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
