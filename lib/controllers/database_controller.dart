import 'package:daily_planner/models/task.dart';
import 'package:hive/hive.dart';

class DBController {

  static DBController? _instance;
  late Box<Task> box; // Change this to your specific Hive box

  DBController._();

  factory DBController.getInstance() {
    _instance ??= DBController._();
    return _instance!;
  }

  Future<void> initialize() async {
    Hive.registerAdapter(TaskAdapter());
    box = await Hive.openBox('tasks');
  }

  // Add methods for database operations

  List<Task> getTasksForDay(DateTime day) {
    var tasksForToday = box.values.where((element) {
      return element.dateTime.day == DateTime.now().day &&
          element.dateTime.month == DateTime.now().month &&
          element.dateTime.year == DateTime.now().year;
    }).toList();
    return tasksForToday;
  }

  List<Task> getTasksForIndicator(DateTime day) {
    var morning = DateTime(day.year, day.month, day.day, 5);
    var tommorow = DateTime(day.year, day.month, day.day, 5).add(const Duration(days: 1));
    // today from 5 am and tommorow till 5 am
    var tasksForToday = box.values.where((element) {
      return element.dateTime.isAfter(morning) &&
          element.dateTime.isBefore(tommorow);
    }).toList();
    return tasksForToday;
  }

  List<Task> getNextNTasksFromToday(int n, int page) {
    var tasksForToday = box.values.where((element) {
      return element.dateTime.isAfter(DateTime.now()) ||
          (element.dateTime.day == DateTime.now().day &&
              element.dateTime.month == DateTime.now().month &&
              element.dateTime.year == DateTime.now().year);
    }).toList();
    tasksForToday.sort((a, b) => a.dateTime.compareTo(b.dateTime));  // TODO: I realy have to get it all at once? like, no internal paging?
    return tasksForToday;
  }

  List<Task> getNextNTasksBeforeToday(int n, int page) {
    var tasksForToday = box.values.where((element) {
      return element.dateTime.isBefore(DateTime.now()) ||
          (element.dateTime.day == DateTime.now().day &&
              element.dateTime.month == DateTime.now().month &&
              element.dateTime.year == DateTime.now().year);
    }).toList();
    tasksForToday.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return tasksForToday.sublist(page * n, (page + 1) * n);
  }

  int addTask(Task task) {
    box.put(task.id, task);
    return task.id;
  }

  void removeTask(Task task) {
    box.delete(task.id);
  }
}