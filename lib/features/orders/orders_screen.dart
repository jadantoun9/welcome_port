import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/orders/orders_provider.dart';
import 'package:welcome_port/features/orders/widgets/orders_list.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrdersProvider(),
      child: _OrdersContent(),
    );
  }
}

class _OrdersContent extends StatefulWidget {
  const _OrdersContent();

  @override
  State<_OrdersContent> createState() => _OrdersContentState();
}

class _OrdersContentState extends State<_OrdersContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrdersProvider>(context, listen: false).loadOrders();
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
      Provider.of<OrdersProvider>(context, listen: false).loadMoreOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrdersProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
          'Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => ordersProvider.refreshOrders(),
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: const SizedBox(height: 10)),
          // Orders Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Order History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  // Only show loader when loading more orders (not initial load)
                  if (ordersProvider.isLoading &&
                      ordersProvider.orders.isNotEmpty)
                    Loader(color: Colors.black),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Orders List
          SliverToBoxAdapter(child: OrdersList(provider: ordersProvider)),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
