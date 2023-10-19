import 'package:flutter/material.dart';

class CalItemHeader extends StatelessWidget {
  const CalItemHeader({Key? key, required this.date}) : super(key: key);

  final String date;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(date),
    );
  }
}
