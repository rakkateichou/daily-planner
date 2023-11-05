import 'dart:async';

import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/utils.dart';
import 'package:flutter/material.dart';

class EditingController extends ChangeNotifier {
  late bool isEditing;

  static EditingController? _instance;

  EditingController._();

  factory EditingController.getInstance() {
    _instance ??= EditingController._();
    return _instance!;
  }

  Future<void> initialize() async {
    isEditing = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggleEditing() {
    isEditing = !isEditing;
    notifyListeners();
  }
}
