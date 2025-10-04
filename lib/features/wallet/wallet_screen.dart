import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/analytics/facebook_analytics_engine.dart';
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
    FacebookAnalyticsEngine.logPageView(pageName: 'Wallet');
    // Load initial transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).loadTransactions();
      Provider.of<SharedProvider>(context, listen: false).refreshSetting();
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
    final l10n = AppLocalizations.of(context)!;

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
        title: Text(
          l10n.wallet,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // Refresh both balance and transactions
              await Future.wait([
                sharedProvider.refreshSetting(),
                walletProvider.refreshTransactions(),
              ]);
            },
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
                walletProvider.showTopUpDialog(context, sharedProvider);
              },
            ),
          ),
          // Transactions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    l10n.transactionHistory,
                    style: const TextStyle(
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
}
