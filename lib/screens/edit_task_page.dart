import 'package:daily_planner/components/edit_new_page_layout.dart';
import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/models/task.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditTaskPage extends StatefulWidget {
  const EditTaskPage({Key? key}) : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();

  static const String routeName = '/edit_task';
}

class _EditTaskPageState extends State<EditTaskPage> {
  final db = DBController.getInstance();
  final cc = ColorController.getInstance();

  late Task task;
  Task? taskToEdit;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    task = ModalRoute.of(context)!.settings.arguments as Task;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: cc.secondaryColor,
        onPressed: () {
          db.updateTask(taskToEdit ?? task);
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editTaskTitle),
        backgroundColor: cc.primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              db.updateTask(taskToEdit ?? task);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              56 -
              MediaQuery.of(context).padding.top,
          child: EditNewPageLayout(
            taskToEdit: task,
            taskCallback: (task) => {
              setState(() {
                taskToEdit = task;
              })
            },
            popCallback: () => {Navigator.pop(context)},
          ),
        ),
      ),
    );
  }
}
