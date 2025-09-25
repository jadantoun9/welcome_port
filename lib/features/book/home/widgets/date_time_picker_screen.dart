import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/show_error_toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';

class DateTimePickerScreen extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final DateTime? minimumDate;
  final String title;

  const DateTimePickerScreen({
    required this.title,
    super.key,
    this.initialDate,
    this.initialTime,
    this.minimumDate,
  });

  @override
  State<DateTimePickerScreen> createState() => _DateTimePickerScreenState();
}

class _DateTimePickerScreenState extends State<DateTimePickerScreen> {
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  @override
  void initState() {
    super.initState();
    // Ensure selected date is not before minimum date or today
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final initialDate = widget.initialDate ?? todayDate;
    final minimumDate = widget.minimumDate ?? todayDate;

    // Use the later of today or provided minimum date
    final effectiveMinimumDate =
        minimumDate.isAfter(todayDate) ? minimumDate : todayDate;

    if (initialDate.isBefore(effectiveMinimumDate)) {
      _selectedDate = effectiveMinimumDate;
    } else {
      _selectedDate = initialDate;
    }

    _selectedTime =
        widget.initialTime ??
        (widget.initialDate != null
            ? TimeOfDay.fromDateTime(widget.initialDate!)
            : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Calendar Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TableCalendar<dynamic>(
                firstDay: _getEffectiveMinimumDate(),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _selectedDate,
                calendarFormat: _calendarFormat,
                rangeSelectionMode: _rangeSelectionMode,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                enabledDayPredicate: (day) {
                  // Disable days before the effective minimum date
                  return !day.isBefore(_getEffectiveMinimumDate());
                },
                onDaySelected: (selectedDay, focusedDay) {
                  // Check if selected day is not before effective minimum date
                  if (selectedDay.isBefore(_getEffectiveMinimumDate())) {
                    return; // Don't allow selection before minimum date
                  }

                  if (!isSameDay(_selectedDate, selectedDay)) {
                    setState(() {
                      _selectedDate = selectedDay;
                    });
                  }
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  defaultDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  weekendDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  disabledTextStyle: TextStyle(color: Colors.grey[400]),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Time Selection Row
            Container(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: _showTimePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.time,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      _selectedTime != null
                          ? Row(
                            children: [
                              Text(
                                "(${_selectedTime!.format(context)})",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _format24Hour(_selectedTime!),
                                  style: const TextStyle(
                                    fontSize: 19,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Text(
                            AppLocalizations.of(context)!.selectTime,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Action Buttons
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: WideButton(
                  text: AppLocalizations.of(context)!.done,
                  onPressed: _confirmSelection,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker() {
    // Initialize with current selected time or current time
    TimeOfDay tempSelectedTime = _selectedTime ?? TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.selectTime,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedTime = tempSelectedTime;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.done,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time Picker
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: DateTime(
                        2024,
                        1,
                        1,
                        tempSelectedTime.hour,
                        tempSelectedTime.minute,
                      ),
                      onDateTimeChanged: (DateTime newDateTime) {
                        tempSelectedTime = TimeOfDay.fromDateTime(newDateTime);
                      },
                      use24hFormat: true,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmSelection() {
    if (_selectedTime == null) {
      showErrorToast(
        context,
        AppLocalizations.of(context)!.validationErrorSelectTime,
      );
      return;
    }

    final DateTime selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    Navigator.pop(context, selectedDateTime);
  }

  DateTime _getEffectiveMinimumDate() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final minimumDate = widget.minimumDate;

    if (minimumDate == null) {
      return todayDate;
    }

    // Return the later of today or the provided minimum date
    return minimumDate.isAfter(todayDate) ? minimumDate : todayDate;
  }

  String _format24Hour(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
