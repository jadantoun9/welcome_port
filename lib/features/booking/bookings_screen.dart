import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/booking/bookings_provider.dart';
import 'package:welcome_port/features/booking/widgets/orders_list.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BookingsProvider(),
      child: _BookingsContent(),
    );
  }
}

class _BookingsContent extends StatefulWidget {
  const _BookingsContent();

  @override
  State<_BookingsContent> createState() => _BookingsContentState();
}

class _BookingsContentState extends State<_BookingsContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingsProvider>(context, listen: false).loadBookings();
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
      Provider.of<BookingsProvider>(context, listen: false).loadMoreBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsProvider = Provider.of<BookingsProvider>(context);

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
          'Bookings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => bookingsProvider.refreshBookings(),
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
                    'Booking History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  // Only show loader when loading more orders (not initial load)
                  if (bookingsProvider.isLoading &&
                      bookingsProvider.bookings.isNotEmpty)
                    Loader(color: Colors.black),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Orders List
          SliverToBoxAdapter(child: BookingsList(provider: bookingsProvider)),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
