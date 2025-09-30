import 'package:flutter/material.dart';
import 'package:welcome_port/features/booking/models/order.dart';
import 'package:welcome_port/features/booking/bookings_service.dart';

class BookingsProvider extends ChangeNotifier {
  final BookingsService _bookingsService = BookingsService();

  List<OrderModel> bookings = [];
  bool isLoading = false;
  bool hasMoreData = true;
  int currentPage = 1;
  final int limit = 50;
  String? error;

  Future<void> loadBookings({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      currentPage = 1;
      bookings.clear();
      hasMoreData = true;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _bookingsService.getBookings(
      limit: limit,
      page: currentPage,
    );

    result.fold(
      (error) {
        this.error = error;
        isLoading = false;
        notifyListeners();
      },
      (newBookings) {
        if (refresh) {
          bookings = newBookings;
        } else {
          bookings.addAll(newBookings);
        }

        hasMoreData = newBookings.length == limit;
        currentPage++;
        isLoading = false;
        this.error = null;
        notifyListeners();
      },
    );
  }

  Future<void> loadMoreBookings() async {
    if (!hasMoreData || isLoading) return;
    await loadBookings();
  }

  Future<void> refreshBookings() async {
    await loadBookings(refresh: true);
  }
}
