import 'package:flutter/material.dart';
import 'package:flutter_intl_phone_field/phone_number.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/models/setting.dart';
import 'package:welcome_port/features/book/booking_details/booking_details_service.dart';
import 'package:welcome_port/features/book/booking_details/models/flight_suggestion.dart';
import 'package:welcome_port/features/book/home/utils/utils.dart';
import 'package:welcome_port/features/book/home/widgets/date_time_picker_screen.dart';
import 'package:welcome_port/features/book/quotes/models/prebook_requirements_response.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/features/order_details/order_details_screen.dart';

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
  bool isBooking = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Title options - will be initialized with localized strings
  late final List<String> titleOptions;

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
    _initializeTitleOptions();
    _initializeForm();
    _initializeAges();
    _initializePickupDate();
  }

  void _initializeTitleOptions() {
    // Initialize with localized title options
    titleOptions = ['Mr', 'Ms', 'Mrs', 'Miss', 'Dr', 'Prof'];
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
      infantAges.add('2');
    }

    // Initialize child ages as null
    childAges.clear();
    for (int i = 0; i < preBookRequirementsResponse.passengers.children; i++) {
      childAges.add('10');
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

  void setIsBooking(bool loading) {
    isBooking = loading;
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
      DateTimePickerScreen(
        initialDate: initialDate,
        initialTime: initialTime,
        title: isDeparture ? 'Departure Date' : 'Return Date',
      ),
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

  String? validateEmail(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.emailIsRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return l.pleaseEnterValidEmailAddress;
    }
    return null;
  }

  String? validatePhoneNumber(PhoneNumber? phoneNumber, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (phoneNumber == null || phoneNumber.completeNumber.isEmpty) {
      return l.phoneNumberIsRequired;
    }
    return null;
  }

  String? validateAgeSelection(
    String? value,
    String fieldName,
    BuildContext context,
  ) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty || value == l.selectAge) {
      return l.ageIsRequired(fieldName);
    }
    return null;
  }

  String? validateTitle(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Check the actual selected title value
    final actualValue = selectedTitle;
    if (actualValue.isEmpty || actualValue == l.selectTitle) {
      return l.titleIsRequired;
    }
    return null;
  }

  String? validateDepartureDate(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.departureDateIsRequired;
    }
    return null;
  }

  String? validateReturnDate(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (preBookRequirementsResponse.isOneWay) return null;
    if (value == null || value.isEmpty) {
      return l.returnDateIsRequired;
    }
    return null;
  }

  String? validateFlightNumber(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.flightNumberIsRequired;
    }
    return null;
  }

  String? validateAddress(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.addressIsRequired;
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
    if (isBooking) return;
    final l = AppLocalizations.of(context)!;
    if (!validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.pleaseFillInAllRequiredFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setIsBooking(true);
    final result = await bookingDetailsService.preBook(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(error)),
        );
        setIsBooking(false);
      },
      (success) async {
        if (sharedProvider.customer?.type == CustomerType.agent) {
          final result = await bookingDetailsService.bookWithBalance();
          setIsBooking(false);

          result.fold(
            (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Colors.red, content: Text(error)),
              );
            },
            (reference) {
              NavigationUtils.push(
                context,
                OrderDetailsScreen(orderReference: reference),
              );
            },
          );
        }
      },
    );
  }

  String getButtonText(SharedProvider sharedProvider, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (sharedProvider.customer?.type == CustomerType.agent) {
      return l.bookNow;
    }
    return l.continueToPayment;
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
