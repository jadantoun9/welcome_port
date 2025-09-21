import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/show_error_toast.dart';

class DateTimePickerScreen extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final DateTime? minimumDate;

  const DateTimePickerScreen({
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
    // Ensure selected date is not before minimum date
    final initialDate = widget.initialDate ?? DateTime.now();
    final minimumDate = widget.minimumDate;

    if (minimumDate != null && initialDate.isBefore(minimumDate)) {
      _selectedDate = minimumDate;
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
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Date & Time',
          style: TextStyle(
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
              padding: const EdgeInsets.all(16),
              child: TableCalendar<dynamic>(
                firstDay: widget.minimumDate ?? DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _selectedDate,
                calendarFormat: _calendarFormat,
                rangeSelectionMode: _rangeSelectionMode,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  // Check if selected day is not before minimum date
                  if (widget.minimumDate != null &&
                      selectedDay.isBefore(widget.minimumDate!)) {
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
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: Colors.grey[300]!),
                  //   borderRadius: BorderRadius.circular(8),
                  // ),
                  child: Row(
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Select time',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              _selectedTime != null
                                  ? Colors.black
                                  : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
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
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                    const Text(
                      'Select Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
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
                  initialDateTime:
                      _selectedTime != null
                          ? DateTime(
                            2024,
                            1,
                            1,
                            _selectedTime!.hour,
                            _selectedTime!.minute,
                          )
                          : DateTime.now(),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedTime = TimeOfDay.fromDateTime(newDateTime);
                    });
                  },
                  use24hFormat: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmSelection() {
    if (_selectedTime == null) {
      showErrorToast(context, 'Please select a time');
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
}
