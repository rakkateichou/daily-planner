import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  int id; // Unique identifier for the task

  @HiveField(1)
  String content; // Content of the task

  @HiveField(2)
  DateTime dateTime; // Date and time for the task

  Task({required this.id, required this.content, required this.dateTime});
}
