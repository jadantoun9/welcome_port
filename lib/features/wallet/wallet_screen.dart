import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/models/setting.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/features/wallet/wallet_provider.dart';
import 'package:welcome_port/features/wallet/widgets/wallet_balance_card.dart';
import 'package:welcome_port/features/wallet/widgets/transaction_list.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WalletProvider(),
      child: _WalletContent(),
    );
  }
}

class _WalletContent extends StatefulWidget {
  const _WalletContent();

  @override
  State<_WalletContent> createState() => _WalletContentState();
}

class _WalletContentState extends State<_WalletContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).loadTransactions();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<WalletProvider>(
        context,
        listen: false,
      ).loadMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);

    if (sharedProvider.customer != null &&
        sharedProvider.customer?.type == CustomerType.customer) {
      return Container();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
        title: const Text(
          'Wallet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => walletProvider.refreshTransactions(),
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Wallet Balance Card
          SliverToBoxAdapter(
            child: WalletBalanceCard(
              balance: sharedProvider.customer?.balanceFormatted ?? "",
              onTopUpPressed: () {
                _showTopUpDialog(context, walletProvider);
              },
            ),
          ),
          // Transactions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Transaction History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Transaction List
          SliverToBoxAdapter(child: TransactionList(provider: walletProvider)),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, WalletProvider walletProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Top Up Wallet'),
          content: const Text('Top up functionality will be implemented here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Add \$10'),
            ),
          ],
        );
      },
    );
  }
}
