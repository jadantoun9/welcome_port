import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/singletons.dart';

class OTPTimer {
  static const String otpTimerEndDateKey = "otp_timer_end_date";
  static const String otpResendCounter = "otp_resend_counter";

  static int recoveryMinutes = 40;
  static int maxAllowedRequests = 10; // allowed otp requests per day
  static int timeInterval = 30; // time interval

  static int getRemainingTimeInS() {
    int timerEndDateMs =
        (Singletons.sharedPref.getInt(otpTimerEndDateKey)) ??
        DateTime.now().millisecondsSinceEpoch;

    if (timerEndDateMs < DateTime.now().millisecondsSinceEpoch) {
      return 0;
    }
    return (timerEndDateMs - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
  }

  static bool canRequest() {
    return getRemainingTimeInS() == 0;
  }

  static String getFormattedRemainingTime(
    BuildContext context, {
    required bool fromOutside,
  }) {
    int remainingTimeInS = getRemainingTimeInS();

    int hours = remainingTimeInS ~/ 3600;
    int minutes = (remainingTimeInS % 3600) ~/ 60;
    int seconds = remainingTimeInS % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  static otpSent() {
    // retrieving stored otpCounter from shared preferences
    int? storedOTPResendCounter =
        Singletons.sharedPref.getInt(otpResendCounter) ?? 0;

    int timerEndDateMs =
        (Singletons.sharedPref.getInt(otpTimerEndDateKey)) ??
        DateTime.now().millisecondsSinceEpoch;

    int resendCounter =
        _isLessThanXMinsAgo(minutes: recoveryMinutes, time: timerEndDateMs)
            ? storedOTPResendCounter
            : 0;

    // changing resend counter
    if (resendCounter < maxAllowedRequests) {
      resendCounter++;
      Singletons.sharedPref.setInt(otpResendCounter, resendCounter);
    }

    // changing remaining time
    late DateTime newTimerEndDate;

    if (resendCounter < maxAllowedRequests) {
      newTimerEndDate = DateTime.now().add(
        Duration(seconds: resendCounter * timeInterval),
      );
    } else {
      newTimerEndDate = DateTime.now().add(const Duration(days: 1));
    }
    timerEndDateMs = newTimerEndDate.millisecondsSinceEpoch;
    Singletons.sharedPref.setInt(otpTimerEndDateKey, timerEndDateMs);
  }

  static bool _isLessThanXMinsAgo({required int minutes, required int time}) {
    return DateTime.now()
            .subtract(Duration(minutes: minutes))
            .millisecondsSinceEpoch <
        time;
  }
}
