import 'dart:io';
import 'dart:ui';

import 'package:daily_planner/controllers/color_controller.dart';
import 'package:daily_planner/controllers/database_controller.dart';
import 'package:daily_planner/controllers/selecting_controller.dart';
import 'package:daily_planner/navigator_service.dart';
import 'package:daily_planner/screens/calendar_page.dart';
import 'package:daily_planner/screens/edit_task_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

import 'screens/home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  await Hive.initFlutter();
  await DBController.getInstance().initialize();
  await ColorController.getInstance().initialize();
  await SelectingController.getInstance().initialize();
  await initializeDateFormatting(Platform.localeName, null);
  await initNotifications();
  tz.initializeTimeZones();
  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));
  Intl.defaultLocale = await findSystemLocale();
  runApp(const MyApp());
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher_foreground');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Planner',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: HomePage.routeName,
      navigatorObservers: [NavigatorService.routeObserver],
      // onGenerateRoute: (settings) {
      //   // maintainState: false,

      //   return PageRouteBuilder(
      //     settings: settings,
      //     maintainState: false,
      //     pageBuilder: (context, animation, secondaryAnimation) {
      //       return FadeTransition(
      //         opacity: animation,
      //         child: const HomePage(),
      //       );
      //     },
      //   );
      // },
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
      navigatorKey: NavigatorService.navigatorKey,
      theme: ThemeData(
          fontFamily: "SofiaSans", useMaterial3: false),
    );
  }
}
