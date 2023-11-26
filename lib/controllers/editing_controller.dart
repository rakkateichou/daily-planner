
import 'package:daily_planner/models/task.dart';
import 'package:flutter/material.dart';

class EditingController extends ChangeNotifier {
  late bool isEditing = false;
  Task? taskToEdit;

  static EditingController? _instance;

  EditingController._();

  factory EditingController.getInstance() {
    _instance ??= EditingController._();
    return _instance!;
  }

  void toggleEditing() {
    if (isEditing) {
      taskToEdit = null;
    }
    isEditing = !isEditing;
    notifyListeners();
  }

  void startEditing(Task task) {
    taskToEdit = task;
    isEditing = true;
    notifyListeners();
  }
}
