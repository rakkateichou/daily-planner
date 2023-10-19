// import 'dart:async';
// import 'package:flutter/foundation.dart';

// class TimerController extends ChangeNotifier {
//   static TimerController? _instance;
//   late Timer _timer;

//   TimerController._() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       notifyListeners();
//     });
//   }

//   factory TimerController.getInstance() {
//     _instance ??= TimerController._(); 
//     return _instance!;
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }
// }
