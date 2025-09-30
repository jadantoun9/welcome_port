import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/book/home/home_provider.dart';

String formatDateTime(DateTime dateTime) {
  final locale = Singletons.sharedPref.getString('locale') ?? 'en';
  final formatter = DateFormat('dd/MM/yyyy HH:mm', locale);
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

/// Parses a date string in format "dd/MM/yyyy HH:mm" and returns a complete DateTime object
/// Returns null if parsing fails
DateTime? parseFullDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }

  try {
    final parsed = parseDateTimeString(dateString);
    final date = parsed['date'] as DateTime?;
    final time = parsed['time'] as TimeOfDay?;

    if (date == null || time == null) {
      return null;
    }

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  } catch (e) {
    return null;
  }
}

String getPassengerSummary(HomeProvider provider) {
  final totalPassengers = provider.adults + provider.children + provider.babies;

  return totalPassengers.toString();
}

String formatTimeWithBothFormats(DateTime dateTime, BuildContext context) {
  final time24 =
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  final timeOfDay = TimeOfDay.fromDateTime(dateTime);
  final timeAmPm = timeOfDay.format(context);
  return '$time24 ($timeAmPm)';
}

/// Formats date for display in the UI
/// Shows date only if time is midnight, otherwise shows date and time
String formatDateTimeForDisplay(DateTime? dateTime, BuildContext context) {
  if (dateTime == null) return '';

  if (dateTime.hour == 0 && dateTime.minute == 0) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${formatTimeWithBothFormats(dateTime, context)}';
  }
}

DateTime getEffectiveMinimumDate(DateTime? minimumDate) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  if (minimumDate == null) {
    return todayDate;
  }

  // Return the later of today or the provided minimum date
  return minimumDate.isAfter(todayDate) ? minimumDate : todayDate;
}

String format24Hour(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
