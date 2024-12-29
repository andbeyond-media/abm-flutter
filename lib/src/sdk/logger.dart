// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';

import '../../andbeyondmedia.dart';

enum Logger {
  debug,
  info,
  error,
}

void log(String msg) {
  debugPrint("ABM : $msg");
}

extension LoggerExtensions on Logger {
  void log(String msg, [String tag = tag]) {
    switch (this) {
      case Logger.debug:
        debugPrint("$tag : $msg");
      case Logger.info:
        print("$tag : $msg");
      case Logger.error:
        debugPrint("$tag : $msg");
    }
  }
}

extension StringExtensions on String {
  void log(String Function() getMessage) {
    final specialTag = AndBeyondMedia.instance.specialTag;
    if (specialTag != null && specialTag.isNotEmpty) {
      print("$specialTag($this) ~ ${getMessage()}");
    }
  }
}
