import 'dart:async';

import 'package:daily_planner/models/task.dart';
import 'package:flutter/material.dart';

class SelectingController extends ChangeNotifier {
  late bool isSelectingMode;
  late List<Task> selectedTasks;

  static SelectingController? _instance;

  SelectingController._();

  factory SelectingController.getInstance() {
    _instance ??= SelectingController._();
    return _instance!;
  }

  Future<void> initialize() async {
    isSelectingMode = false;
    selectedTasks = [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void quitSelecting() {
    isSelectingMode = false;
    selectedTasks = [];
    notifyListeners();
  }

  bool checkSelected(Task task) => selectedTasks.contains(task);

  void onLongPress(Task task) {
    if (!isSelectingMode) {
      isSelectingMode = true;
      selectedTasks.add(task);
    } else {
      if (selectedTasks.contains(task)) {
        selectedTasks.remove(task);
      } else {
        selectedTasks.add(task);
      }
      if (selectedTasks.isEmpty) {
        isSelectingMode = false;
      }
    }
    notifyListeners();
  }

  void onTap(Task task) {
    if (isSelectingMode) {
      if (selectedTasks.contains(task)) {
        selectedTasks.remove(task);
        if (selectedTasks.isEmpty) {
          isSelectingMode = false;
        }
      } else {
        selectedTasks.add(task);
      }
    }
    notifyListeners();
  }
}
