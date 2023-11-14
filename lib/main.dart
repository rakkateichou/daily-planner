import 'dart:ui';

import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:daily_planner/screens/calendar_page.dart';
import 'package:daily_planner/screens/edit_task_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'screens/home_page.dart';

void main() async {
  await Hive.initFlutter();
  await DBController.getInstance().initialize();
  await ColorController.getInstance().initialize();
  await SelectingController.getInstance().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Planner',
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        CalendarPage.routeName: (context) => const CalendarPage(),
        EditTaskPage.routeName: (context) => const EditTaskPage(),
      },
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      theme: ThemeData(fontFamily: 'Itim', useMaterial3: false),
    );
  }
}
