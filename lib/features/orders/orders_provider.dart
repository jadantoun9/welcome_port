import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/widgets/confirmation_dialog.dart';
import 'package:welcome_port/features/orders/models/order.dart';
import 'package:welcome_port/features/orders/orders_service.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersService _ordersService = OrdersService();

  List<OrderModel> bookings = [];
  bool isLoading = false;
  bool hasMoreData = true;
  int currentPage = 1;
  final int limit = 50;
  String? error;
  String? acceptError;
  String searchQuery = '';
  Timer? _debounceTimer;

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

    final result = await _ordersService.getBookings(
      limit: limit,
      page: currentPage,
      search: searchQuery,
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

  void updateSearchQuery(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set the search query immediately for UI feedback
    searchQuery = query;
    notifyListeners();

    // Debounce the actual search by 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      loadBookings(refresh: true);
    });
  }

  void clearSearch() {
    searchQuery = '';
    notifyListeners();
    loadBookings(refresh: true);
  }

  void onAccept(BuildContext context, String orderReference) {
    final l10n = AppLocalizations.of(context)!;

    // Create a ValueNotifier that will update when the provider's error changes
    final errorNotifier = ValueNotifier<String>(acceptError ?? '');

    // Function to update the error notifier when provider changes
    void updateErrorNotifier() {
      errorNotifier.value = acceptError ?? '';
    }

    // Add the listener
    addListener(updateErrorNotifier);

    showConfirmationDialog(
      context: context,
      title: l10n.acceptBooking,
      message: l10n.areYouSureAcceptBooking,
      confirmButtonText: l10n.accept,
      errorNotifier: errorNotifier,
      onConfirm: () async {
        final result = await _acceptBooking(orderReference);
        if (result && context.mounted) {
          return true;
        }
        return false;
      },
    ).then((confirmed) {
      // Clean up when dialog is closed
      removeListener(updateErrorNotifier);
      errorNotifier.dispose();

      // If accept was successful, refresh bookings
      if (confirmed && context.mounted) {
        refreshBookings();
      }

      // Clear any errors
      acceptError = null;
    });
  }

  Future<bool> _acceptBooking(String orderReference) async {
    acceptError = null;
    notifyListeners();

    final result = await _ordersService.acceptBooking(
      orderReference: orderReference,
    );

    var success = false;
    result.fold(
      (error) {
        acceptError = error;
        success = false;
        notifyListeners();
      },
      (accepted) {
        success = true;
        notifyListeners();
      },
    );
    return success;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
