import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';
import 'package:welcome_port/features/book/home/models/airport_suggestion.dart';
import 'package:welcome_port/features/book/home/models/gm_location.dart';
import 'package:welcome_port/core/widgets/input_container.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';
import 'package:welcome_port/features/book/home/home_provider.dart';
import 'package:welcome_port/features/book/home/models/location_type.dart';
import 'package:welcome_port/features/book/home/widgets/date_time_picker_screen.dart';
import 'package:welcome_port/features/book/home/widgets/location_picker_screen.dart';
import 'package:welcome_port/features/book/home/widgets/passenger_picker_screen.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/features/book/home/widgets/coupon_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeProvider(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    AppLocalizations.of(context)!.bookTransfer,
                    style: TextStyle(
                      color: Colors.grey[100],
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.quickEasyAirportTransfers,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // Trip Type Selection
                  _buildTripTypeSelector(provider),
                  const SizedBox(height: 20),

                  // Location Fields
                  _buildLocationFields(provider),
                  const SizedBox(height: 20),

                  // Flight Date
                  _buildFlightDateField(provider),
                  const SizedBox(height: 20),

                  // Return Date (if round trip)
                  // if (provider.tripType == TripType.roundTrip) ...[
                  _buildReturnDateField(provider),
                  const SizedBox(height: 20),
                  // ],

                  // Passenger Selection
                  _buildPassengerSelector(provider),
                  const SizedBox(height: 30),

                  // Search Button
                  WideButton(
                    text: AppLocalizations.of(context)!.searchBooking,
                    onPressed: () => provider.handleSearch(context, provider),
                    isLoading: provider.isLoading,
                    bgColor: Colors.amber,
                  ),
                  const SizedBox(height: 16),

                  // Coupon Section
                  _buildCouponSection(provider),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTripTypeSelector(HomeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTripTypeOption(
              provider,
              TripType.oneWay,
              AppLocalizations.of(context)!.oneWay,
              Icons.flight,
            ),
          ),
          Expanded(
            child: _buildTripTypeOption(
              provider,
              TripType.roundTrip,
              AppLocalizations.of(context)!.roundTrip,
              Icons.swap_horiz,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeOption(
    HomeProvider provider,
    TripType tripType,
    String label,
    IconData icon,
  ) {
    final isSelected = provider.tripType == tripType;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        provider.setTripType(tripType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationFields(HomeProvider provider) {
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Column(
      children: [
        // Pickup Location
        _buildLocationField(
          provider,
          sharedProvider,
          label: AppLocalizations.of(context)!.pickupLocation,
          hintText: AppLocalizations.of(context)!.searchLocation,
          controller: provider.pickupController,
          focusNode: provider.pickupFocus,
          isPickupField: true,
          onLocationSelected: (Either<GMLocation, AirportSuggestion> location) {
            provider.setPickupLocation(location);
          },
        ),
        const SizedBox(height: 16),
        // Destination Location
        _buildLocationField(
          provider,
          sharedProvider,
          label: AppLocalizations.of(context)!.destinationLocation,
          hintText: AppLocalizations.of(context)!.searchLocation,
          controller: provider.destinationController,
          focusNode: provider.destinationFocus,
          isPickupField: false,
          onLocationSelected: (Either<GMLocation, AirportSuggestion> location) {
            provider.setDestinationLocation(location);
          },
        ),
      ],
    );
  }

  Widget _buildLocationField(
    HomeProvider provider,
    SharedProvider sharedProvider, {
    required String label,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    // required bool isAirport,
    required Function(Either<GMLocation, AirportSuggestion>) onLocationSelected,
    required bool isPickupField,
  }) {
    return InputContainer(
      label: label,
      child: InkwellWithOpacity(
        onTap: () async {
          final otherLocation =
              isPickupField
                  ? provider.destinationLocation
                  : provider.pickupLocation;

          // Determine restriction based on other location type
          LocationType? restrictToDirection;
          if (otherLocation != null) {
            otherLocation.fold(
              (gmLocation) {
                // If other location is GMLocation (place), restrict this to airport
                restrictToDirection = LocationType.airport;
              },
              (airportSuggestion) {
                // If other location is AirportSuggestion (airport), restrict this to place
                restrictToDirection = LocationType.place;
              },
            );
          }

          await NavigationUtils.push<Either<GMLocation, AirportSuggestion>>(
            context,
            LocationPickerScreen(
              restrictToDirection: restrictToDirection,
              title: label,
              hintText: hintText,
              googleMapsApiKey: sharedProvider.setting?.gmApiKey ?? '',
              onSubmit: onLocationSelected,
              selectedLocation: otherLocation?.fold(
                (gmLocation) => gmLocation,
                (airport) => null,
              ),
              selectedAirport: otherLocation?.fold(
                (gmLocation) => null,
                (airport) => airport,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.black, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.text.isNotEmpty ? controller.text : hintText,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              if ((isPickupField && provider.pickupLocation != null) ||
                  (!isPickupField && provider.destinationLocation != null)) ...[
                IconButton(
                  onPressed: () {
                    if (isPickupField) {
                      provider.setPickupLocation(null);
                    } else {
                      provider.setDestinationLocation(null);
                    }
                  },
                  icon: const Icon(Icons.close, color: Colors.black, size: 20),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightDateField(HomeProvider provider) {
    return InputContainer(
      label: AppLocalizations.of(context)!.flightTime,
      child: InkwellWithOpacity(
        onTap: () async {
          final DateTime? newSelectedDateTime =
              await NavigationUtils.push<DateTime>(
                context,
                DateTimePickerScreen(
                  initialDate: provider.flightDate,
                  title: AppLocalizations.of(context)!.flightTime,
                ),
              );

          if (newSelectedDateTime != null) {
            provider.setFlightDate(newSelectedDateTime);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.black, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  provider.flightDate != null
                      ? (provider.flightDate!.hour == 0 &&
                              provider.flightDate!.minute == 0
                          ? '${provider.flightDate!.day}/${provider.flightDate!.month}/${provider.flightDate!.year}'
                          : '${provider.flightDate!.day}/${provider.flightDate!.month}/${provider.flightDate!.year} ${_formatTimeWithBothFormats(provider.flightDate!)}')
                      : AppLocalizations.of(context)!.selectFlightTime,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReturnDateField(HomeProvider provider) {
    if (provider.tripType == TripType.oneWay) {
      return InkwellWithOpacity(
        onTap: () {
          HapticFeedback.mediumImpact();
          provider.setTripType(TripType.roundTrip);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.addReturn,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return InputContainer(
      label: AppLocalizations.of(context)!.returnFlightTime,
      child: InkWell(
        onTap: () async {
          final DateTime? newSelectedDateTime =
              await NavigationUtils.push<DateTime>(
                context,
                DateTimePickerScreen(
                  title: AppLocalizations.of(context)!.returnFlightTime,
                  initialDate: provider.returnFlightDate,
                  minimumDate: provider.flightDate,
                ),
              );

          if (newSelectedDateTime != null) {
            provider.setReturnFlightDate(newSelectedDateTime);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.black, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  provider.returnFlightDate != null
                      ? (provider.returnFlightDate!.hour == 0 &&
                              provider.returnFlightDate!.minute == 0
                          ? '${provider.returnFlightDate!.day}/${provider.returnFlightDate!.month}/${provider.returnFlightDate!.year}'
                          : '${provider.returnFlightDate!.day}/${provider.returnFlightDate!.month}/${provider.returnFlightDate!.year} ${_formatTimeWithBothFormats(provider.returnFlightDate!)}')
                      : AppLocalizations.of(context)!.selectReturnFlightTime,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerSelector(HomeProvider provider) {
    return InputContainer(
      label: AppLocalizations.of(context)!.passengers,
      child: InkwellWithOpacity(
        onTap: () async {
          final PassengerData? result =
              await NavigationUtils.push<PassengerData>(
                context,
                PassengerPickerScreen(
                  initialAdults: provider.adults,
                  initialChildren: provider.children,
                  initialInfants: provider.babies,
                ),
              );

          if (result != null) {
            provider.setAdults(result.adults);
            provider.setChildren(result.children);
            provider.setBabies(result.infants);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.black, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _getPassengerSummary(provider),
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getPassengerSummary(HomeProvider provider) {
    final totalPassengers =
        provider.adults + provider.children + provider.babies;

    if (provider.adults == 1 &&
        provider.children == 0 &&
        provider.babies == 0) {
      return AppLocalizations.of(context)!.selectPassengers;
    }

    return totalPassengers.toString();
  }

  String _formatTimeWithBothFormats(DateTime dateTime) {
    final time24 =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    final timeAmPm = timeOfDay.format(context);
    return '$time24 ($timeAmPm)';
  }

  Widget _buildCouponSection(HomeProvider provider) {
    return Center(
      child: Column(
        children: [
          if (provider.isCouponApplied) ...[
            // Applied coupon display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.couponApplied(provider.appliedCoupon ?? ''),
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      provider.setAppliedCoupon(null);
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.green[600],
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Have a coupon text
            GestureDetector(
              onTap: () async {
                final couponCode = await showCouponDialog(context: context);
                if (couponCode != null &&
                    couponCode.isNotEmpty &&
                    context.mounted) {
                  await provider.handleApplyCoupon(context, couponCode);
                }
              },
              child: Text(
                AppLocalizations.of(context)!.haveCoupon,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decorationColor: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
