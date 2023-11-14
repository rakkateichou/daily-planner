import 'dart:async';

import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/utils.dart';
import 'package:flutter/material.dart';

// TODO: i should delete this and replace it with db listener
class DayTasksController extends ChangeNotifier {
  List<Task> tasks = [];
  DBController db = DBController.getInstance();

  static DayTasksController? _instance;

  DayTasksController._();

  factory DayTasksController.getInstance() {
    _instance ??= DayTasksController._();
    return _instance!;
  }

  Future<void> initialize() async {
    fetchTasks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setTasks(List<Task> tasks) {
    this.tasks = tasks;
    notifyListeners();
  }

  void removeTask(Task task) {
    tasks.remove(task);
    notifyListeners();
  }

  void removeTasks(List<Task> tasks) {
    this.tasks.removeWhere((element) => tasks.contains(element));
    notifyListeners();
  }

  void addTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  void fetchTasks() {
    tasks = db.getTasksForDay(DateTime.now());
    notifyListeners();
  }
}
