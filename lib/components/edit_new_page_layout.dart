import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EditNewPageLayout extends StatefulWidget {
  const EditNewPageLayout(
      {Key? key,
      required this.taskCallback,
      required this.popCallback,
      this.taskToEdit})
      : super(key: key);

  final Task? taskToEdit;
  final Function(Task task) taskCallback;
  final VoidCallback popCallback;

  @override
  _EditNewPageLayoutState createState() => _EditNewPageLayoutState();
}

class _EditNewPageLayoutState extends State<EditNewPageLayout> {
  late TextEditingController _controller;
  late DateTime _dateTime;
  late String _timeText;
  late String _dateText;

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    if (widget.taskToEdit == null) {
      _dateTime = DateTime.now();
      _timeText = DateFormat.jm().format(now);
      _dateText = DateFormat.yMMMMd().format(now);
      _controller = TextEditingController();
      _controller.addListener(() {
        _callCallback();
      });
    } else {
      _dateTime = widget.taskToEdit!.dateTime;
      _timeText = DateFormat.jm().format(_dateTime);
      _dateText = DateFormat.yMMMMd().format(_dateTime);
      _controller = TextEditingController(text: widget.taskToEdit!.content);
      _controller.addListener(() {
        _callCallback();
      });
    }
  }

  void _pickTime() {
    Future<TimeOfDay?> selectedTime = showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    selectedTime.asStream().first.then((value) {
      if (value != null) {
        setState(() {
          _timeText = value.format(context);
          _dateTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
              value.hour, value.minute);
        });
        _callCallback();
      }
    });
  }

  void _pickDate() {
    Future<DateTime?> selectedDate = showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: DateTime.now().add(const Duration(days: 50000)),
    );
    selectedDate.asStream().first.then((value) {
      if (value != null) {
        setState(() {
          _dateText = DateFormat.yMMMMd().format(value);
          _dateTime = DateTime(value.year, value.month, value.day,
              _dateTime.hour, _dateTime.minute);
        });
        _callCallback();
      }
    });
  }

  void _callCallback() {
    widget.taskCallback(Task(
        id: widget.taskToEdit?.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        content: _controller.text,
        dateTime: _dateTime));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.popCallback();
        return false;
      },
      child: Column(
        children: [
          Container(
              height: 575, child: NoteLikeTextField(controller: _controller)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                width: 141,
                height: 72,
                child: Text(
                  "What time do you want to put the task on?",
                  style: MyTextStyles.taskEditingStyle,
                ),
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 3),
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: MyPickContainer(text: _timeText),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: MyPickContainer(text: _dateText),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class MyPickContainer extends StatelessWidget {
  const MyPickContainer({
    super.key,
    required String text,
  }) : pickedText = text;

  final String pickedText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: const BoxDecoration(color: Color(0xCCF2F2F3)),
      child: SizedBox(
        width: 200,
        height: 25,
        child: Text(
          pickedText,
          textAlign: TextAlign.center,
          style: MyTextStyles.taskEditingStyle,
        ),
      ),
    );
  }
}

class NoteLikeTextField extends StatelessWidget {
  const NoteLikeTextField({
    super.key,
    required TextEditingController controller,
  }) : _controller = controller;

  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 16,
          right: 16,
          bottom: 10,
          child: TextField(
            onChanged: (value) {
              _controller.text = value;
            },
            maxLength: 450,
            style: MyTextStyles.taskEditingStyle,
            scrollPhysics: const NeverScrollableScrollPhysics(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Type your task here',
            ),
            // space between lines
            strutStyle: const StrutStyle(
              height: 1.3,
            ),
            maxLines: 18,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            controller: _controller,
          ),
        ),
        for (var i = 0; i < 18; i++)
          Positioned(
            left: 16,
            right: 16,
            bottom: i * 26.0 + 40,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              color: Color(0xA6000000),
            ),
          ),
      ],
    );
  }
}
