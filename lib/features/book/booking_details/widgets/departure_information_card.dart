import 'package:flutter/material.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          isDeparture
              ? AppLocalizations.of(context)!.departureInformation
              : AppLocalizations.of(context)!.returnInformation,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 24),

        // Origin Section
        _buildLocationSection(
          context: context,
          title: AppLocalizations.of(context)!.from,
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
          title: AppLocalizations.of(context)!.to,
          // destination of return is the origin of departure (the one object returned represents departure)
          location:
              isDeparture
                  ? provider.preBookRequirementsResponse.destination
                  : provider.preBookRequirementsResponse.origin,
          isOrigin: false,
          isDeparture: isDeparture,
        ),
      ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location Header
        Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$title: ',
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]!),
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
            label: AppLocalizations.of(context)!.pickupDate,
            icon: Icons.calendar_today,
            backgroundColor: Colors.white,
            placeholder: AppLocalizations.of(context)!.pickupDate,
            onClick: () async {
              provider.onPickUpDateClick(context, isDeparture);
            },
            validator:
                (value) =>
                    isDeparture
                        ? provider.validateDepartureDate(value, context)
                        : provider.validateReturnDate(value, context),
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
            validator: (value) => provider.validateFlightNumber(value, context),
          ),
        ] else ...[
          // Location - Ask for Address Details
          if (isDeparture)
            BookingTextfield(
              controller: provider.addressDetailsController,
              label: 'Additional Directions (Optional)',
              icon: Icons.location_on,
              backgroundColor: Colors.white,
              // validator: (value) => provider.validateAddress(value, context),
              validator: (value) => null,
            ),
        ],
      ],
    );
  }
}
