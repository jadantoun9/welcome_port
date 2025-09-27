import 'package:flutter/material.dart';
import 'package:welcome_port/features/wallet/model/transaction.dart';
import 'package:welcome_port/features/wallet/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final WalletService _walletService = WalletService();

  List<Transaction> transactions = [];
  bool isLoading = false;
  bool hasMoreData = true;
  int currentPage = 1;
  final int limit = 10;
  String? error;

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
      (error) {
        error = error;
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
}
