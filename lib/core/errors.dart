import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

String friendlyError(Object e) {
  if (e is SocketException) return 'No internet connection';
  if (e is TimeoutException) return 'Request timed out. Try again';
  if (e is ApiException) return e.message;
  if (e is PlatformException) return e.message ?? 'Something went wrong';
  if (e is FormatException) return 'Unexpected server response';
  return 'Something went wrong';
}
