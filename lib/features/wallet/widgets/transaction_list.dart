import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/widgets/error_card.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/wallet/model/transaction.dart';
import 'package:welcome_port/features/wallet/wallet_provider.dart';

class TransactionList extends StatelessWidget {
  final WalletProvider provider;

  const TransactionList({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.error != null) {
      return _buildErrorWidget();
    }

    if (provider.transactions.isEmpty && !provider.isLoading) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        // Header Row
        _buildHeaderRow(),

        // Transactions List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              provider.transactions.length + (provider.hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.transactions.length) {
              return _buildLoadMoreButton();
            }

            final transaction = provider.transactions[index];
            return _buildTransactionItem(transaction);
          },
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[500]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Description Header
              Expanded(
                flex: 2,
                child: Text(
                  l10n.description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // In/Out Header
              Expanded(
                flex: 1,
                child: Text(
                  l10n.inOut,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.all(20),
          child: ErrorCard(
            title: l10n.failedToLoadTransactions,
            message: provider.error ?? l10n.unknownError,
            onRetry: () => provider.refreshTransactions(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noTransactionsYet,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.transactionHistoryWillAppearHere,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreButton() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.all(16),
          child:
              provider.isLoading
                  ? Loader(color: Colors.black, size: 22)
                  : ElevatedButton(
                    onPressed: provider.loadMoreTransactions,
                    child: Text(l10n.loadMore),
                  ),
        );
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Description Column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.dateAdded,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // In/Out Column (Amount)
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.amountFormatted,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: transaction.amount > 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.balanceFormatted,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
