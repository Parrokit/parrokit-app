import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:logger/logger.dart';

/// 앱 전역에서 사용하는 정적 로거 유틸
class AppLogger {
  // static logger instance
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 80,
      colors: false,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // 스택 트레이스 없는 단순 로거 (라우팅 등)
  static final Logger _simpleLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: false,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void d(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  static void i(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  static void w(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: error != null ? message?.toString() : null,
      );
    }
  }

  static void t(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.t(message, error: error, stackTrace: stackTrace);

  static void f(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);

  /// 라우팅 로그용 (스택 없음)
  static void r(dynamic message) => _simpleLogger.i(message);
}
