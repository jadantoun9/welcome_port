import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('dd/MM/yyyy HH:mm');
  return formatter.format(dateTime);
}

/// Parses a date string in format "dd/MM/yyyy HH:mm" and returns DateTime and TimeOfDay objects
/// Returns null values if parsing fails
Map<String, dynamic> parseDateTimeString(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return {'date': null, 'time': null};
  }

  try {
    // Parse format: "dd/MM/yyyy HH:mm"
    final parts = dateString.split(' ');
    if (parts.length != 2) {
      return {'date': null, 'time': null};
    }

    final datePart = parts[0]; // "dd/MM/yyyy"
    final timePart = parts[1]; // "HH:mm"

    final dateComponents = datePart.split('/');
    if (dateComponents.length != 3) {
      return {'date': null, 'time': null};
    }

    final day = int.parse(dateComponents[0]);
    final month = int.parse(dateComponents[1]);
    final year = int.parse(dateComponents[2]);

    final timeComponents = timePart.split(':');
    if (timeComponents.length != 2) {
      return {'date': null, 'time': null};
    }

    final hour = int.parse(timeComponents[0]);
    final minute = int.parse(timeComponents[1]);

    return {
      'date': DateTime(year, month, day),
      'time': TimeOfDay(hour: hour, minute: minute),
    };
  } catch (e) {
    // If parsing fails, return null values
    return {'date': null, 'time': null};
  }
}
