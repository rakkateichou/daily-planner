import 'dart:async';

import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/utils.dart';
import 'package:flutter/material.dart';

class SearchingController extends ChangeNotifier {
  late bool isSearching = false;
  String query = "";

  static SearchingController? _instance;

  SearchingController._();

  factory SearchingController.getInstance() {
    _instance ??= SearchingController._();
    return _instance!;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggleSeaching() {
    if (isSearching) {
      query = "";
    }
    isSearching = !isSearching;
    notifyListeners();
  }

  void quitSearching() {
    isSearching = false;
    query = "";
    notifyListeners();
  }

  void updateQuery(String newQuery) {
    query = newQuery;
    notifyListeners();
  }
}
