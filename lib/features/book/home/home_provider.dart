import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:welcome_port/core/analytics/facebook_analytics_engine.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/widgets/show_error_toast.dart';
import 'package:welcome_port/features/book/home/home_service.dart';
import 'package:welcome_port/features/book/home/models/airport_suggestion.dart';
import 'package:welcome_port/features/book/home/models/gm_location.dart';
import 'package:welcome_port/features/book/home/utils/utils.dart';
import 'package:welcome_port/features/book/quotes/quotes_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum TripType { oneWay, roundTrip }

class HomeProvider extends ChangeNotifier {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController couponController = TextEditingController();
  final FocusNode pickupFocus = FocusNode();
  final FocusNode destinationFocus = FocusNode();
  final FocusNode couponFocus = FocusNode();

  final HomeService homeService = HomeService();
  TripType tripType = TripType.oneWay;
  Either<GMLocation, AirportSuggestion>? pickupLocation;
  Either<GMLocation, AirportSuggestion>? destinationLocation;

  // Flight details
  DateTime? flightDate;
  DateTime? returnFlightDate;

  // Passenger counts
  int adults = 1;
  int children = 0;
  int babies = 0;

  bool isLoading = false;

  bool isCouponLoading = false;
  String? couponError;
  String? appliedCoupon;

  HomeProvider() {
    log("logging checkout");
    FacebookAnalyticsEngine.confirmCheckout();
  }

  void setTripType(TripType type) {
    tripType = type;
    notifyListeners();
  }

  void setPickupLocation(Either<GMLocation, AirportSuggestion>? location) {
    if (location == null) {
      pickupController.text = '';
      pickupLocation = null;
      notifyListeners();
      return;
    }
    pickupController.text = location.fold(
      (gmLocation) => gmLocation.mainText,
      (airport) => airport.name,
    );
    pickupLocation = location;
    notifyListeners();
  }

  void setDestinationLocation(Either<GMLocation, AirportSuggestion>? location) {
    if (location == null) {
      destinationController.text = '';
      destinationLocation = null;
      notifyListeners();
      return;
    }
    destinationController.text = location.fold(
      (gmLocation) => gmLocation.mainText,
      (airport) => airport.name,
    );
    destinationLocation = location;
    notifyListeners();
  }

  void setFlightDate(DateTime? date) {
    flightDate = date;
    notifyListeners();
  }

  void setReturnFlightDate(DateTime? date) {
    // Validate that return date is after the main flight date
    if (date != null && flightDate != null) {
      if (date.isBefore(flightDate!)) {
        // Don't set the date if it's before the main flight date
        return;
      }
    }
    returnFlightDate = date;
    notifyListeners();
  }

  // Check if return date is valid (after main flight date)
  bool get isReturnDateValid {
    if (returnFlightDate == null || flightDate == null) return true;
    return !returnFlightDate!.isBefore(flightDate!);
  }

  void setAdults(int count) {
    if (count >= 1) {
      adults = count;
      notifyListeners();
    }
  }

  void setChildren(int count) {
    if (count >= 0) {
      children = count;
      notifyListeners();
    }
  }

  void setBabies(int count) {
    if (count >= 0) {
      babies = count;
      notifyListeners();
    }
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setCouponLoading(bool value) {
    isCouponLoading = value;
    notifyListeners();
  }

  void setCouponError(String? value) {
    couponError = value;
    notifyListeners();
  }

  void setAppliedCoupon(String? value) {
    appliedCoupon = value;
    notifyListeners();
  }

  // Reset form
  void resetForm() {
    setPickupLocation(null);
    setDestinationLocation(null);

    notifyListeners();
  }

  // Handle search with validation
  Future<void> handleSearch(BuildContext context, HomeProvider provider) async {
    // Validation
    if (pickupLocation == null || destinationLocation == null) {
      showErrorToast(
        context,
        AppLocalizations.of(context)!.validationErrorSelectPickupDestination,
      );
      return;
    }
    if (flightDate == null) {
      showErrorToast(
        context,
        AppLocalizations.of(context)!.validationErrorSelectFlightDate,
      );
      return;
    }
    if (tripType == TripType.roundTrip && returnFlightDate == null) {
      showErrorToast(
        context,
        AppLocalizations.of(context)!.validationErrorSelectReturnDate,
      );
      return;
    }
    if (tripType == TripType.roundTrip && !isReturnDateValid) {
      showErrorToast(
        context,
        AppLocalizations.of(context)!.validationErrorReturnDateAfterFlight,
      );
      return;
    }
    if (adults < 1) {
      showErrorToast(
        context,
        AppLocalizations.of(context)!.validationErrorAtLeastOneAdult,
      );
      return;
    }

    // GMLocation origin;
    // AirportSuggestion destination;
    String originString = '';
    String destinationString;
    String locationName;
    String locationAddress;

    var origin = pickupLocation!.fold(
      (gmLocation) => gmLocation,
      (airport) => airport,
    );

    if (origin is GMLocation) {
      originString =
          "coords:${origin.latLng.latitude},${origin.latLng.longitude}";
      locationName = origin.mainText;
      locationAddress =
          origin.secondaryText.isNotEmpty
              ? origin.secondaryText
              : origin.mainText;

      final destination =
          destinationLocation!.fold(
                (gmLocation) => gmLocation,
                (airport) => airport,
              )
              as AirportSuggestion;

      destinationString = "iata:${destination.code}";
    } else {
      origin = origin as AirportSuggestion;

      originString = "iata:${origin.code}";

      final destination =
          destinationLocation!.fold(
                (gmLocation) => gmLocation,
                (airport) => airport,
              )
              as GMLocation;

      destinationString =
          "coords:${destination.latLng.latitude},${destination.latLng.longitude}";
      locationName = destination.mainText;
      locationAddress =
          destination.secondaryText.isNotEmpty
              ? destination.secondaryText
              : destination.mainText;
    }

    String outwardDateString = formatDateTime(flightDate!);

    String returnDateString =
        returnFlightDate != null && TripType.roundTrip == tripType
            ? formatDateTime(returnFlightDate!)
            : "";

    setLoading(true);

    final quotes = await homeService.getQuotes(
      origin: originString,
      destination: destinationString,
      locationName: locationName,
      locationAddress: locationAddress,
      outwardDate: outwardDateString,
      returnDate: returnDateString,
      adults: adults,
      children: children,
      babies: babies,
      coupon: appliedCoupon ?? '',
    );

    quotes.fold(
      (error) {
        showErrorToast(context, error);
      },
      (quotes) {
        NavigationUtils.push(context, QuotesScreen(quotesResponse: quotes));
      },
    );

    setLoading(false);
  }

  Future<void> handleApplyCoupon(
    BuildContext context,
    String couponCode,
  ) async {
    setCouponLoading(true);
    setCouponError(null);

    final result = await homeService.applyCoupon(coupon: couponCode);

    result.fold(
      (error) {
        setCouponError(error);
        showErrorToast(context, error);
      },
      (response) {
        setAppliedCoupon(couponCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(AppLocalizations.of(context)!.couponSuccess),
          ),
        );
      },
    );

    setCouponLoading(false);
  }

  @override
  void dispose() {
    pickupController.dispose();
    destinationController.dispose();
    couponController.dispose();
    pickupFocus.dispose();
    destinationFocus.dispose();
    couponFocus.dispose();
    super.dispose();
  }
}
