import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/models/setting.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/show_error_toast.dart';
import 'package:welcome_port/features/book/booking_details/widgets/payment_method_bottom_sheet.dart';
import 'package:welcome_port/features/wallet/model/transaction.dart';
import 'package:welcome_port/features/wallet/wallet_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/features/payment/top_up_webview.dart';
import 'package:welcome_port/features/wallet/widgets/amount_input_bottom_sheet.dart';

class WalletProvider extends ChangeNotifier {
  final WalletService _walletService = WalletService();

  List<Transaction> transactions = [];
  bool isLoading = false;
  bool hasMoreData = true;
  int currentPage = 1;
  final int limit = 10;
  String? error;

  final ValueNotifier<bool> isTopUpLoadingNotifier = ValueNotifier<bool>(false);

  PaymentMethod? selectedPaymentMethod;
  double? topUpAmount;

  void setSelectedPaymentMethod(PaymentMethod paymentMethod) {
    selectedPaymentMethod = paymentMethod;
    notifyListeners();
  }

  Future<void> loadTransactions({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      currentPage = 1;
      transactions.clear();
      hasMoreData = true;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _walletService.getTransactions(
      limit: limit,
      page: currentPage,
    );

    result.fold(
      (err) {
        error = err;
        isLoading = false;
        notifyListeners();
      },
      (newTransactions) {
        if (refresh) {
          transactions = newTransactions;
        } else {
          transactions.addAll(newTransactions);
        }

        hasMoreData = newTransactions.length == limit;
        currentPage++;
        isLoading = false;
        error = null;
        notifyListeners();
      },
    );
  }

  Future<void> loadMoreTransactions() async {
    if (!hasMoreData || isLoading) return;
    await loadTransactions();
  }

  Future<void> refreshTransactions() async {
    await loadTransactions(refresh: true);
  }

  void showTopUpDialog(BuildContext context, SharedProvider sharedProvider) {
    final l = AppLocalizations.of(context)!;
    final paymentMethods = sharedProvider.setting?.paymentMethods ?? [];

    if (paymentMethods.isEmpty) {
      showErrorToast(context, l.noPaymentMethodsAvailable);
      return;
    }

    // First show amount input bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (bottomSheetContext) => AmountInputBottomSheet(
            onNextPressed: (amount) {
              // Store the amount
              topUpAmount = amount;

              // Close the amount input bottom sheet
              Navigator.pop(bottomSheetContext);

              // Show payment method selection bottom sheet
              _showPaymentMethodBottomSheet(context, sharedProvider);
            },
          ),
    );
  }

  void _showPaymentMethodBottomSheet(
    BuildContext context,
    SharedProvider sharedProvider,
  ) {
    final paymentMethods = sharedProvider.setting?.paymentMethods ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (bottomSheetContext) => PaymentMethodBottomSheet(
            paymentMethods: paymentMethods,
            isLoadingNotifier: isTopUpLoadingNotifier,
            onPaymentMethodSelected: (paymentMethod) {
              setSelectedPaymentMethod(paymentMethod);
            },
            onPayPressed: () async {
              if (selectedPaymentMethod == null || topUpAmount == null) return;

              // Navigator.pop(bottomSheetContext); // Close bottom sheet
              isTopUpLoadingNotifier.value = true;

              final result = await _walletService.topUpWallet(
                amount: topUpAmount!,
                paymentMethodCode: selectedPaymentMethod!.code,
              );

              isTopUpLoadingNotifier.value = false;

              result.fold(
                (error) {
                  showErrorToast(context, error);
                },
                (url) {
                  // Navigate to payment webview using parent context
                  NavigationUtils.push(context, TopUpWebview(url: url));
                },
              );
            },
          ),
    );
  }
}
