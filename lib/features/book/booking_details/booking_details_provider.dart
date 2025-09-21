import 'package:flutter/material.dart';
import 'package:flutter_intl_phone_field/phone_number.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/features/book/booking_details/booking_details_service.dart';
import 'package:welcome_port/features/book/booking_details/models/flight_suggestion.dart';
import 'package:welcome_port/features/book/home/home_provider.dart';
import 'package:welcome_port/features/book/home/utils/utils.dart';
import 'package:welcome_port/features/book/home/widgets/date_time_picker_screen.dart';
import 'package:welcome_port/features/book/quotes/models/prebook_requirements_response.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';

class BookingDetailsProvider extends ChangeNotifier {
  final bookingDetailsService = BookingDetailsService();
  final PreBookRequirementsResponse preBookRequirementsResponse;
  final SharedProvider sharedProvider;

  // Form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final phoneFocusNode = FocusNode();

  // Departure information controllers
  final flightNumberController = TextEditingController();
  final returnFlightNumberController = TextEditingController();
  final addressDetailsController = TextEditingController();

  final departureDateController = TextEditingController();
  final returnDateController = TextEditingController();

  // Form state
  String selectedTitle = 'Mr';
  bool isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Title options
  final List<String> titleOptions = ['Mr', 'Mrs', 'Ms'];

  // Children and infants ages
  final List<String?> infantAges = [];
  final List<String?> childAges = [];

  // Flight suggestions
  FlightSuggestion? departureFlight;
  FlightSuggestion? returnFlight;

  BookingDetailsProvider(
    this.preBookRequirementsResponse,
    this.sharedProvider,
  ) {
    _initializeForm();
    _initializeAges();
    _initializePickupDate();
  }

  void _initializeForm() {
    // Fill form with customer data if logged in
    if (sharedProvider.customer != null) {
      final customer = sharedProvider.customer!;
      firstNameController.text = customer.firstName;
      lastNameController.text = customer.lastName;
      phoneController.text = customer.phone;
      emailController.text = customer.email;
    }
  }

  void _initializeAges() {
    // Initialize infant ages as null
    infantAges.clear();
    for (int i = 0; i < preBookRequirementsResponse.passengers.infants; i++) {
      infantAges.add(null);
    }

    // Initialize child ages as null
    childAges.clear();
    for (int i = 0; i < preBookRequirementsResponse.passengers.children; i++) {
      childAges.add(null);
    }
  }

  void _initializePickupDate() {
    // Set default pickup date from preBookRequirementsResponse
    departureDateController.text =
        preBookRequirementsResponse.outwardFromPickupDate;
    returnDateController.text =
        preBookRequirementsResponse.returnFromPickupDate ?? '';
  }

  void updateTitle(String title) {
    selectedTitle = title;
    notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void setDepartureFlight(FlightSuggestion flight) {
    departureFlight = flight;
    flightNumberController.text = flight.flightNumber;
    notifyListeners();
  }

  void setReturnFlight(FlightSuggestion flight) {
    returnFlight = flight;
    returnFlightNumberController.text = flight.flightNumber;
    notifyListeners();
  }

  void updateInfantAge(int index, String? age) {
    if (index < infantAges.length) {
      infantAges[index] = age;
      notifyListeners();
    }
  }

  void updateChildAge(int index, String? age) {
    if (index < childAges.length) {
      childAges[index] = age;
      notifyListeners();
    }
  }

  void updatePickupDate(String date) {
    departureDateController.text = date;
    notifyListeners();
  }

  void updateReturnDate(String date) {
    returnDateController.text = date;
    notifyListeners();
  }

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    phoneController.text = phoneNumber.completeNumber;
    notifyListeners();
  }

  String? getInfantAge(int index) {
    return infantAges[index];
  }

  String? getChildAge(int index) {
    return childAges[index];
  }

  void onPickUpDateClick(BuildContext context, bool isDeparture) async {
    final defaultValue =
        isDeparture
            ? preBookRequirementsResponse.outwardFromPickupDate
            : preBookRequirementsResponse.returnFromPickupDate;

    final parsedDateTime = parseDateTimeString(defaultValue);
    final DateTime? initialDate = parsedDateTime['date'];
    final TimeOfDay? initialTime = parsedDateTime['time'];

    final result = await NavigationUtils.push(
      context,
      DateTimePickerScreen(initialDate: initialDate, initialTime: initialTime),
    );

    if (result != null && result is DateTime) {
      if (isDeparture) {
        updatePickupDate(formatDateTime(result));
      } else {
        updateReturnDate(formatDateTime(result));
      }
    }
  }

  bool get isFormValid {
    return _isCustomerInfoValid() &&
        _isChildrenAgesValid() &&
        _isDepartureInfoValid();
  }

  bool _isCustomerInfoValid() {
    return selectedTitle.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty;
  }

  bool _isChildrenAgesValid() {
    // Check if all infant ages are specified
    for (String? age in infantAges) {
      if (age == null) return false;
    }

    // Check if all child ages are specified
    for (String? age in childAges) {
      if (age == null) return false;
    }

    return true;
  }

  bool _isDepartureInfoValid() {
    final isDepartureCompleted =
        departureDateController.text.isNotEmpty &&
        flightNumberController.text.isNotEmpty &&
        addressDetailsController.text.isNotEmpty;

    final isReturnCompleted =
        returnDateController.text.isNotEmpty &&
        returnFlightNumberController.text.isNotEmpty;

    return isDepartureCompleted &&
        (isReturnCompleted || preBookRequirementsResponse.isOneWay);
  }

  // Validation methods for individual fields
  String? validateRequired(String? value, String fieldName) {
    // For text fields, the value parameter should contain the controller text
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhoneNumber(PhoneNumber? phoneNumber) {
    if (phoneNumber == null || phoneNumber.completeNumber.isEmpty) {
      return 'Phone number is required';
    }
    return null;
  }

  String? validateAgeSelection(String? value, String fieldName) {
    if (value == null || value.isEmpty || value == 'Select age') {
      return '$fieldName age is required';
    }
    return null;
  }

  String? validateTitle(String? value) {
    // Check the actual selected title value
    final actualValue = selectedTitle;
    if (actualValue.isEmpty || actualValue == 'Select title') {
      return 'Title is required';
    }
    return null;
  }

  String? validateDepartureDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Departure date is required';
    }
    return null;
  }

  String? validateReturnDate(String? value) {
    if (preBookRequirementsResponse.isOneWay) return null;
    if (value == null || value.isEmpty) {
      return 'Return date is required';
    }
    return null;
  }

  String? validateFlightNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Flight number is required';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    return null;
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  String _extractAgeNumber(String ageString) {
    // Extract just the number from strings like "11 years" or "4"
    final match = RegExp(r'(\d+)').firstMatch(ageString);
    return match?.group(1) ?? '0';
  }

  void onSubmit({required BuildContext context}) async {
    if (!validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final result = await bookingDetailsService.book(
      title: selectedTitle,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      telephone: phoneController.text,
      email: emailController.text,
      childrenAges:
          childAges
              .where((age) => age != null && age.isNotEmpty)
              .map((age) => _extractAgeNumber(age!))
              .where((age) => age.isNotEmpty)
              .toList(),
      infantAges:
          infantAges
              .where((age) => age != null && age.isNotEmpty)
              .map((age) => _extractAgeNumber(age!))
              .where((age) => age.isNotEmpty)
              .toList(),
      departureDate: departureDateController.text,
      returnDate: returnDateController.text,
      flightNumber: flightNumberController.text,
      returnFlightNumber: returnFlightNumberController.text,
      airlineCode: departureFlight?.airlineCode ?? '',
      returnAirlineCode: returnFlight?.airlineCode ?? '',
      addressDetails: addressDetailsController.text,
      isOneWay: preBookRequirementsResponse.isOneWay,
      isLocationToAirport:
          preBookRequirementsResponse.direction == TripDirection.toAirport,
    );
    result.fold(
      (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      },
      (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(success.toString())));
      },
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    phoneFocusNode.dispose();
    flightNumberController.dispose();
    returnFlightNumberController.dispose();
    addressDetailsController.dispose();
    departureDateController.dispose();
    returnDateController.dispose();
    super.dispose();
  }
}
