import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/singletons.dart';

String _getLocalizedErrorMessage(String key) {
  final locale = Singletons.sharedPref.getString('locale') ?? 'en';

  switch (key) {
    case 'defaultError':
      return locale == 'ar'
          ? 'حدث خطأ غير متوقع!'
          : 'An unexpected error occurred!';
    case 'connectionError':
      return locale == 'ar'
          ? 'يرجى التحقق من الاتصال والمحاولة مرة أخرى!'
          : 'Please check your connection and try again!';
    default:
      return key;
  }
}

String getDefaultErrorMessage() {
  return _getLocalizedErrorMessage('defaultError');
}

String getMessageFromError(DioException exception) {
  if (exception.response.toString().startsWith('<!DOCTYPE')) {
    return getDefaultErrorMessage();
  }

  if (exception.type == DioExceptionType.connectionError ||
      exception.type == DioExceptionType.connectionTimeout ||
      exception.type == DioExceptionType.sendTimeout ||
      exception.type == DioExceptionType.receiveTimeout) {
    return _getLocalizedErrorMessage('connectionError');
  }

  if (exception.response == null) {
    return getDefaultErrorMessage();
  }

  if (exception.response?.data == null) {
    return getDefaultErrorMessage();
  } else if (exception.response?.data != null) {
    debugPrint(exception.response?.data.toString());
  }

  // Check if 'error' exists and handle different types
  if (exception.response!.data['error'] != null) {
    final error = exception.response!.data['error'];

    // Handle error as Map (e.g., {warning: "Type required"})
    if (error is Map<String, dynamic>) {
      // Check for common error keys
      if (error['warning'] is String && error['warning'].isNotEmpty) {
        return error['warning'];
      }
      if (error['message'] is String && error['message'].isNotEmpty) {
        return error['message'];
      }
      if (error['error'] is String && error['error'].isNotEmpty) {
        return error['error'];
      }
      // If it's a map but no recognizable error message, try to get first string value
      for (final value in error.values) {
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    // Handle error as List (existing logic)
    if (error is List) {
      final errorList = error;

      // Check if the list is not empty before accessing index 0
      if (errorList.isNotEmpty) {
        if (errorList[0] is List) {
          final nestedErrorList = errorList[0] as List;

          // Check if the nested list is not empty before accessing index 0
          if (nestedErrorList.isNotEmpty && nestedErrorList[0] is String) {
            return nestedErrorList[0];
          }
        } else if (errorList[0] is String) {
          return errorList[0];
        }
      }
    }

    // Handle error as String
    if (error is String && error.isNotEmpty) {
      return error;
    }
  }

  // Check if there's a message field
  if (exception.response!.data['message'] is String) {
    return exception.response!.data['message'];
  }

  return getDefaultErrorMessage();
}
