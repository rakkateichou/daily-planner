import 'package:daily_planner/components/cal_list.dart';
import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/searching_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:flutter/material.dart';

import '../components/calendar_app_bar.dart';
import '../models/cal_list_type.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();

  static const String routeName = '/calendar';
}

class _CalendarPageState extends State<CalendarPage> {
  final cc = ColorController.getInstance();
  final src = SearchingController.getInstance();
  final slc = SelectingController.getInstance();

  late CalListType type;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    type = ModalRoute.of(context)!.settings.arguments as CalListType;

    return WillPopScope(
      onWillPop: () async {
        if (slc.isSelectingMode) {
          slc.quitSelecting();
          return false;
        }
        if (src.isSearching) {
          src.quitSearching();
          return false;
        }
        return true;
      },
      child: ListenableBuilder(
        listenable: src,
        builder: (context, child) => Scaffold(
            appBar: PreferredSize(
                preferredSize: src.isSearching
                    ? const Size.fromHeight(112.0)
                    : const Size.fromHeight(56.0),
                child: CalendarAppBar(
                    title: type == CalListType.nextTasks
                        ? AppLocalizations.of(context)!.tasksTitle
                        : AppLocalizations.of(context)!.pastTasksTitle)),
            body: CalList(type: type)),
      ),
    );
  }
}
