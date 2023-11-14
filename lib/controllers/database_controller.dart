import 'package:daily_planner/models/task.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DBController extends ChangeNotifier{
  static DBController? _instance;
  late Box<Task> box; // Change this to your specific Hive box
  Task? lastDeleteTask;

  DBController._();

  factory DBController.getInstance() {
    _instance ??= DBController._();
    return _instance!;
  }

  Future<void> initialize() async {
    Hive.registerAdapter(TaskAdapter());
    box = await Hive.openBox('tasks');
  }

  List<Task> getTasksForDay(DateTime day) {
    var tasksForDay = box.values.where((element) {
      return element.dateTime.day == DateTime.now().day &&
          element.dateTime.month == DateTime.now().month &&
          element.dateTime.year == DateTime.now().year;
    }).toList();
    return tasksForDay;
  }

  List<Task> getTasksForIndicator(DateTime day) {
    var morning = DateTime(day.year, day.month, day.day, 5);
    var tommorow =
        DateTime(day.year, day.month, day.day, 5).add(const Duration(days: 1));
    // today from 5 am and tommorow till 5 am
    var tasksForToday = box.values.where((element) {
      return element.dateTime.isAfter(morning) &&
          element.dateTime.isBefore(tommorow);
    }).toList();
    return tasksForToday;
  }

  List<Task> getNextTasks(int n, int page, {String search = ""}) {
    var tasks = box.values.where((element) {
      return (element.dateTime.isAfter(DateTime.now()) ||
          (element.dateTime.day == DateTime.now().day &&
              element.dateTime.month == DateTime.now().month &&
              element.dateTime.year == DateTime.now().year))
              && element.content.toLowerCase().contains(search.toLowerCase());
    }).toList();
    tasks.sort((a, b) => a.dateTime.compareTo(b
        .dateTime)); // TODO: I realy have to get it all at once? like, no internal paging?
    int startIndex = page * n;
    int endIndex = (page + 1) * n;

    if (startIndex >= tasks.length) {
      return [];
    }

    if (endIndex > tasks.length) {
      endIndex = tasks.length;
    }

    return tasks.sublist(startIndex, endIndex);
  }

  List<Task> getPastTasks(int n, int page, {String search = ""}) {
    var tasks = box.values.where((element) {
      return (element.dateTime.isBefore(DateTime.now()) ||
          (element.dateTime.day == DateTime.now().day &&
              element.dateTime.month == DateTime.now().month &&
              element.dateTime.year == DateTime.now().year))
              && element.content.toLowerCase().contains(search.toLowerCase());
    }).toList();
    tasks.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    int startIndex = page * n;
    int endIndex = (page + 1) * n;

    if (startIndex >= tasks.length) {
      return [];
    }

    if (endIndex > tasks.length) {
      endIndex = tasks.length;
    }

    return tasks.sublist(startIndex, endIndex);
  }

  int addTask(Task task) {
    box.put(task.id, task);
    notifyListeners();
    return task.id;
  }

  void updateTask(Task task) {
    print(task.content);
    box.put(task.id, task);
    notifyListeners();
  }

  void removeTask(Task task) {
    lastDeleteTask = task;
    box.delete(task.id);
    notifyListeners();
  }

  void removeTasks(List<Task> tasks) {
    tasks.forEach((element) {
      box.delete(element.id);
    });
    notifyListeners();
  }

  void restoreLastDeleteTask() {
    if (lastDeleteTask != null) {
      box.put(lastDeleteTask!.id, lastDeleteTask!);
    }
    notifyListeners();
  }

}
