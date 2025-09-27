import 'package:flutter/material.dart';
import 'package:welcome_port/features/orders/models/order.dart';
import 'package:welcome_port/features/orders/orders_service.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersService _ordersService = OrdersService();

  List<OrderModel> orders = [];
  bool isLoading = false;
  bool hasMoreData = true;
  int currentPage = 1;
  final int limit = 10;
  String? error;

  Future<void> loadOrders({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      currentPage = 1;
      orders.clear();
      hasMoreData = true;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _ordersService.getOrders(
      limit: limit,
      page: currentPage,
    );

    result.fold(
      (error) {
        this.error = error;
        isLoading = false;
        notifyListeners();
      },
      (newOrders) {
        if (refresh) {
          orders = newOrders;
        } else {
          orders.addAll(newOrders);
        }

        hasMoreData = newOrders.length == limit;
        currentPage++;
        isLoading = false;
        this.error = null;
        notifyListeners();
      },
    );
  }

  Future<void> loadMoreOrders() async {
    if (!hasMoreData || isLoading) return;
    await loadOrders();
  }

  Future<void> refreshOrders() async {
    await loadOrders(refresh: true);
  }
}
