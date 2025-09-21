import 'dart:async';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/widgets/show_error_toast.dart';
import 'package:welcome_port/features/book/home/models/get_quotes_response.dart';
import 'package:welcome_port/core/models/quote.dart';
import 'package:welcome_port/features/book/booking_details/booking_details_screen.dart';
import 'package:welcome_port/features/book/quotes/quotes_service.dart';

class QuotesProvider extends ChangeNotifier {
  final QuotesService quotesService = QuotesService();

  GetQuotesResponse quotesResponse;
  List<Quote> sortedQuotes = [];
  String currentSort = 'none';
  Timer? _sessionTimer;
  late int remainingSeconds; // will be overriden directly
  bool isSessionExpired = false;

  QuotesProvider(this.quotesResponse) {
    sortedQuotes = List.from(quotesResponse.quotes);
    remainingSeconds = quotesResponse.expirationTime;
    _startSessionTimer();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    isSessionExpired = false;

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSeconds--;
      notifyListeners();

      if (remainingSeconds <= 0) {
        isSessionExpired = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void resetSession() {
    _startSessionTimer();
  }

  void setQuotesResponse(GetQuotesResponse quotesResponse) {
    this.quotesResponse = quotesResponse;
    sortedQuotes = List.from(quotesResponse.quotes);
    _startSessionTimer(); // Reset timer when new quotes are loaded
    notifyListeners();
  }

  void sortQuotes(String sortType) {
    currentSort = sortType;

    switch (sortType) {
      case 'high_to_low':
        sortedQuotes.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'low_to_high':
        sortedQuotes.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'none':
      default:
        sortedQuotes = List.from(quotesResponse.quotes);
        break;
    }

    notifyListeners();
  }

  Future<void> bookNow(Quote quote, BuildContext context) async {
    final response = await quotesService.preBook(quote.id);

    response.fold(
      (error) => showErrorToast(context, error),
      (response) => NavigationUtils.push(
        context,
        BookingDetailsScreen(preBookRequirementsResponse: response),
      ),
    );
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
