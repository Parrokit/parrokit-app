import 'package:logger/logger.dart';

/// 앱 전역에서 사용하는 정적 로거 유틸
class PaLogger {
  // static logger instance
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void d(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  static void i(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  static void w(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  static void v(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.v(message, error: error, stackTrace: stackTrace);

  static void wtf(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.wtf(message, error: error, stackTrace: stackTrace);
}