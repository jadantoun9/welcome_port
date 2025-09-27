import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/custom_cached_image.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/book/home/home_provider.dart';
import 'package:welcome_port/features/order_details/models/order_details.dart';
import 'package:welcome_port/features/order_details/order_details_provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderReference;

  const OrderDetailsScreen({super.key, required this.orderReference});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => OrderDetailsProvider()..loadOrderDetails(orderReference),
      child: _OrderDetailsContent(),
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  const _OrderDetailsContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderDetailsProvider>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            'Order Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: Loader(),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.primaryColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            'Order Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error loading order details',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                provider.error ?? 'Unknown error',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final order = provider.orderDetails!;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Visual Summary Section
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Order ID
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Order #${order.reference}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Vehicle image
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomCachedImage(
                        imageUrl: order.vehicle.image,
                        contain: true,
                      ),
                    ),
                  ),

                  // Vehicle details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vehicle name
                        Text(
                          order.vehicle.name,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),

                        _buildCapacityItem(
                          icon: Icons.people,
                          text:
                              'Min 1 - Max ${order.vehicle.maxPassengers} Passengers',
                        ),
                        const SizedBox(height: 10),
                        _buildCapacityItem(
                          icon: Icons.work_outline,
                          text: '${order.vehicle.maxLuggage} Suitcase',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Order details in two columns
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOrderDetail(
                                label: 'Pickup Location',
                                value:
                                    "${order.from} ${order.routeDirection == Direction.airportToLocation ? order.airport.name : '${order.location.name} \n${order.location.directionNote}'}",
                              ),
                              const SizedBox(height: 16),
                              _buildOrderDetail(
                                label: 'Drop-Off Location',
                                value:
                                    "${order.to} ${order.routeDirection == Direction.locationToAirport ? order.airport.name : '${order.location.name} \n${order.location.directionNote}'}",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Right column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOrderDetail(
                                label: 'Passengers',
                                value: _getPassengerSummary(order.passengers),
                              ),
                              const SizedBox(height: 16),
                              _buildOrderDetail(
                                label: 'Flight Date',
                                value: _formatDateString(order.outwardDate),
                              ),
                              const SizedBox(height: 16),
                              if (provider.orderDetails?.tripType ==
                                  TripType.roundTrip)
                                _buildOrderDetail(
                                  label: 'Return Flight Date',
                                  value: _formatDateString(
                                    provider.orderDetails?.returnDate ?? '',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons Section with curved top
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primaryColor,
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 72),
                  child: Column(
                    children: [
                      // View Voucher Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final order = provider.orderDetails;
                            if (order != null) {
                              final url = order.voucher;
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'View Voucher',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Contact Support Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            final url =
                                sharedProvider.setting?.whatsappUrl ?? '';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Need Help? Contact Support',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetail({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDateString(String dateString) {
    return dateString;
  }

  String _getPassengerSummary(passengers) {
    final adults = passengers.adults;
    final children = passengers.children;
    final infants = passengers.infants;

    List<String> parts = [];
    if (adults > 0) parts.add('$adults Adult${adults > 1 ? 's' : ''}');
    if (children > 0) parts.add('$children Children');
    if (infants > 0) parts.add('$infants Infant${infants > 1 ? 's' : ''}');

    return parts.join(', ');
  }
}
