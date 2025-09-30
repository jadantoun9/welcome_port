import 'package:flutter/material.dart';
import 'package:welcome_port/core/widgets/error_card.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/booking/bookings_provider.dart';
import 'package:welcome_port/features/booking/widgets/order_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookingsList extends StatelessWidget {
  final BookingsProvider provider;

  const BookingsList({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.error != null) {
      return _buildErrorWidget();
    }

    if (provider.bookings.isEmpty && !provider.isLoading) {
      return _buildEmptyWidget();
    }

    // Show skeleton when loading and no orders yet
    if (provider.isLoading && provider.bookings.isEmpty) {
      return const BookingsSkeleton(itemCount: 5);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.bookings.length + (provider.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.bookings.length) {
          return _buildLoadMoreButton();
        }

        final order = provider.bookings[index];
        return BookingCard(order: order);
      },
    );
  }

  Widget _buildErrorWidget() {
    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ErrorCard(
                title: "Failed to load bookings",
                message: provider.error ?? 'Unknown error',
                onRetry: () => provider.refreshBookings(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Builder(
      builder: (context) {
        final l = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: Colors.grey[500],
              ),
              const SizedBox(height: 16),
              Text(
                l.noOrdersYet,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.orderHistoryWillAppearHere,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
        final l = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.all(16),
          child:
              provider.isLoading
                  ? Loader(color: Colors.black)
                  : ElevatedButton(
                    onPressed: provider.loadMoreBookings,
                    child: Text(l.loadMore),
                  ),
        );
      },
    );
  }
}

class BookingsSkeleton extends StatelessWidget {
  final int itemCount;

  const BookingsSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) => _buildSkeletonItem()),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Vehicle image skeleton
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          // Order details skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order reference skeleton
              Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              // Route skeleton
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 2),
              // Date skeleton
              Container(
                width: 100,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 2),
              // Trip type skeleton
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          // Status and button skeleton
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    // Status skeleton
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 7),
                    // View button skeleton
                    Container(
                      width: 50,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
