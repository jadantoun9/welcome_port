import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/features/book/booking_details/booking_details_provider.dart';
import 'package:welcome_port/features/book/booking_details/widgets/continue_button.dart';
import 'package:welcome_port/features/book/booking_details/widgets/customer_info_card.dart';
import 'package:welcome_port/features/book/booking_details/widgets/departure_information_card.dart';
import 'package:welcome_port/features/book/quotes/models/prebook_requirements_response.dart';
import 'package:welcome_port/core/widgets/custom_cached_image.dart';

class BookingDetailsScreen extends StatelessWidget {
  final PreBookRequirementsResponse preBookRequirementsResponse;

  const BookingDetailsScreen({
    super.key,
    required this.preBookRequirementsResponse,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => BookingDetailsProvider(
            preBookRequirementsResponse,
            Provider.of<SharedProvider>(context, listen: false),
          ),
      child: const _BookingDetailsContent(),
    );
  }
}

class _BookingDetailsContent extends StatefulWidget {
  const _BookingDetailsContent();

  @override
  State<_BookingDetailsContent> createState() => _BookingDetailsContentState();
}

class _BookingDetailsContentState extends State<_BookingDetailsContent> {
  int luggageCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingDetailsProvider>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          l.bookingDetails,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Visual Summary Section
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle image
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomCachedImage(
                        imageUrl:
                            provider.preBookRequirementsResponse.vehicle.image,
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
                          provider.preBookRequirementsResponse.vehicle.name,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),

                        _buildCapacityItem(
                          icon: Icons.people,
                          text: l.minPassengers(
                            provider
                                .preBookRequirementsResponse
                                .vehicle
                                .maxPassengers,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildCapacityItem(
                          icon: Icons.work_outline,
                          text:
                              '${provider.preBookRequirementsResponse.vehicle.maxLuggage} ${l.suitcase}',
                        ),
                        // Capacity details
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Booking details in two columns
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
                              _buildBookingDetail(
                                label: l.pickupLocation,
                                value: _getLocationName(
                                  provider.preBookRequirementsResponse.origin,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildBookingDetail(
                                label: l.dropOffLocation,
                                value: _getLocationName(
                                  provider
                                      .preBookRequirementsResponse
                                      .destination,
                                ),
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
                              _buildBookingDetail(
                                label: l.passengers,
                                value: _getPassengerSummary(provider),
                              ),
                              const SizedBox(height: 16),
                              _buildBookingDetail(
                                label: "Flight Date",
                                value: _formatDateString(
                                  provider
                                      .preBookRequirementsResponse
                                      .outwardDate,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (!provider
                                  .preBookRequirementsResponse
                                  .isOneWay)
                                _buildBookingDetail(
                                  label: "Return Flight Date",
                                  value: _formatDateString(
                                    provider
                                            .preBookRequirementsResponse
                                            .returnDate ??
                                        '',
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

          // Original Form Section with curved top
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
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 32),
                  child: Form(
                    key: provider.formKey,
                    child: Column(
                      children: [
                        CustomerInfoCard(provider: provider),
                        const SizedBox(height: 24),
                        DepartureReturnCard(
                          provider: provider,
                          isDeparture: true,
                        ),
                        const SizedBox(height: 24),
                        if (!provider.preBookRequirementsResponse.isOneWay) ...[
                          DepartureReturnCard(
                            provider: provider,
                            isDeparture: false,
                          ),
                          const SizedBox(height: 24),
                        ],
                        ContinueButton(
                          provider: provider,
                          text: provider.getButtonText(sharedProvider, context),
                          isBooking: provider.isBooking,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
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

  Widget _buildBookingDetail({required String label, required String value}) {
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
    // Assuming the date string is in a format that can be parsed
    // This is a placeholder - you may need to adjust based on actual format
    return dateString; // For now, return as-is
  }

  String _getLocationName(dynamic location) {
    if (location == null) return 'N/A';

    if (location is ReturnedAirport) {
      return '${location.name} (${location.code})';
    } else if (location is ReturnedGMLocation) {
      return location.name;
    }

    return 'N/A';
  }

  String _getPassengerSummary(BookingDetailsProvider provider) {
    final adults = provider.preBookRequirementsResponse.passengers.adults;
    final children = provider.preBookRequirementsResponse.passengers.children;
    final infants = provider.preBookRequirementsResponse.passengers.infants;

    String s = '$adults Adults';

    if (children > 0) {
      s += ", $children Children";
    }
    if (infants > 0) {
      s += ", $infants Infants";
    }
    return s;
  }
}
