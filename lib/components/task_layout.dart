import 'package:daily_planner/components/task_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class TaskLayout extends StatefulWidget {
  const TaskLayout(
      {Key? key, required this.currentButtonColor})
      : super(key: key);

  final Color currentButtonColor;

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
            itemCount: 10,
            padding: const EdgeInsets.only(bottom: 64, top: 20),
            itemBuilder: (context, index) {
              return TaskItem();
            },
          ),
        ),
        Positioned(
          bottom: 18,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
              backgroundColor: widget.currentButtonColor,
            )),
          ),
        )
      ],
    );
  }
}
