import 'package:flutter/material.dart';

class Logger {
  static LogMode _logMode = LogMode.debug;

  static void init(LogMode mode) {
    Logger._logMode = mode;
  }

  static void log(dynamic data, {StackTrace? stackTrace}) {
    if (_logMode == LogMode.debug) {
      debugPrint("$data${stackTrace ?? ''}");
    }
  }

  static void chatLog(dynamic data, {StackTrace? stackTrace}) {
    debugPrint("$data${stackTrace ?? ''}");
  }
}

enum LogMode { debug, live }
