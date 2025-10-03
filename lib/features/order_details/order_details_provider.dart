import 'package:flutter/material.dart';
import 'package:welcome_port/features/order_details/models/order_details.dart';
import 'package:welcome_port/features/order_details/order_details_service.dart';

class OrderDetailsProvider extends ChangeNotifier {
  final OrderDetailsService _orderDetailsService = OrderDetailsService();

  OrderDetailsModel? orderDetails;
  bool isLoading = false;
  String? error;

  Future<void> loadOrderDetails(String reference, String? email) async {
    isLoading = true;
    error = null;
    notifyListeners();

    late final result;

    if (email != null) {
      result = await _orderDetailsService.getOrderByMail(
        reference: reference,
        email: email,
      );
    } else {
      result = await _orderDetailsService.getOrder(reference: reference);
    }

    result.fold(
      (error) {
        this.error = error;
        isLoading = false;
        notifyListeners();
      },
      (orderDetails) {
        this.orderDetails = orderDetails;
        isLoading = false;
        this.error = null;
        notifyListeners();
      },
    );
  }
}
