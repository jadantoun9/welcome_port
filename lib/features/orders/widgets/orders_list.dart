import 'package:flutter/material.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/orders/orders_provider.dart';
import 'package:welcome_port/features/orders/widgets/order_card.dart';

class OrdersList extends StatelessWidget {
  final OrdersProvider provider;

  const OrdersList({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.error != null) {
      return _buildErrorWidget();
    }

    if (provider.orders.isEmpty && !provider.isLoading) {
      return _buildEmptyWidget();
    }

    // Show skeleton when loading and no orders yet
    if (provider.isLoading && provider.orders.isEmpty) {
      return const OrdersSkeleton(itemCount: 5);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.orders.length + (provider.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.orders.length) {
          return _buildLoadMoreButton();
        }

        final order = provider.orders[index];
        return OrderCard(order: order);
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load orders',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? 'Unknown error',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.refreshOrders(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey[500]),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child:
          provider.isLoading
              ? Loader(color: Colors.black)
              : ElevatedButton(
                onPressed: provider.loadMoreOrders,
                child: const Text('Load More'),
              ),
    );
  }
}

class OrdersSkeleton extends StatelessWidget {
  final int itemCount;

  const OrdersSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) => _buildSkeletonItem()),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Details skeleton
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Amount skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
