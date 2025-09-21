import 'package:flutter/material.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/features/book/booking_details/booking_details_provider.dart';
import 'package:welcome_port/features/book/booking_details/widgets/flight_picker_screen.dart';
import 'package:welcome_port/features/book/booking_details/widgets/reusable/booking_textfield.dart';
import 'package:welcome_port/features/book/quotes/models/prebook_requirements_response.dart';

class DepartureReturnCard extends StatelessWidget {
  final bool isDeparture;
  final BookingDetailsProvider provider;

  const DepartureReturnCard({
    super.key,
    required this.provider,
    required this.isDeparture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flight_takeoff,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isDeparture ? 'Departure Information' : 'Return Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Origin Section
            _buildLocationSection(
              context: context,
              title: 'From',
              // origin of return is the destination of departure (the one object returned represents departure)
              location:
                  isDeparture
                      ? provider.preBookRequirementsResponse.origin
                      : provider.preBookRequirementsResponse.destination,
              isOrigin: true,
              isDeparture: isDeparture,
            ),
            const SizedBox(height: 20),

            // Destination Section
            _buildLocationSection(
              context: context,
              title: 'To',
              // destination of return is the origin of departure (the one object returned represents departure)
              location:
                  isDeparture
                      ? provider.preBookRequirementsResponse.destination
                      : provider.preBookRequirementsResponse.origin,
              isOrigin: false,
              isDeparture: isDeparture,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection({
    required BuildContext context,
    required String title,
    required dynamic location,
    required bool isOrigin,
    required bool isDeparture,
  }) {
    final isAirport = location is ReturnedAirport;
    final locationName =
        isAirport ? '${location.name} (${location.code})' : location.name;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200]!,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isAirport ? Icons.flight : Icons.location_on,
                    color: Colors.grey[800]!,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$title: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800]!,
                          ),
                        ),
                        TextSpan(
                          text: locationName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Input Fields
            // Always ask for Pick up date for both origin and destination
            if (isOrigin) ...[
              BookingTextfield(
                controller:
                    isDeparture
                        ? provider.departureDateController
                        : provider.returnDateController,
                label: 'Pick up date',
                icon: Icons.calendar_today,
                backgroundColor: Colors.white,
                placeholder: 'Pick up date',
                onClick: () async {
                  provider.onPickUpDateClick(context, isDeparture);
                },
                validator:
                    isDeparture
                        ? provider.validateDepartureDate
                        : provider.validateReturnDate,
              ),
              const SizedBox(height: 16),
            ],

            if (isAirport) ...[
              BookingTextfield(
                controller:
                    isOrigin
                        ? provider.flightNumberController
                        : provider.returnFlightNumberController,
                label: 'Flight Number',
                icon: Icons.confirmation_number,
                backgroundColor: Colors.white,
                onClick: () async {
                  NavigationUtils.push(
                    context,
                    FlightPickerScreen(
                      title: 'Flight Number',
                      hintText: 'Flight Number',
                      onSubmit: (flight) {
                        if (isDeparture) {
                          provider.setDepartureFlight(flight);
                        } else {
                          provider.setReturnFlight(flight);
                        }
                      },
                    ),
                  );
                },
                validator: provider.validateFlightNumber,
              ),
            ] else ...[
              // Location - Ask for Address Details
              if (isDeparture)
                BookingTextfield(
                  controller: provider.addressDetailsController,
                  label: 'Address Details',
                  icon: Icons.location_on,
                  backgroundColor: Colors.white,
                  validator: provider.validateAddress,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
