import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint(details.exceptionAsString());
  };

  runApp(await builder());
}
