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
import 'package:welcome_port/features/book/home/widgets/date_time_picker_screen.dart';
import 'package:welcome_port/features/book/home/widgets/location_picker_screen.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/widgets/coupon_dialog.dart';
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

                  // Trip Direction Selection
                  _buildTripDirectionSelector(provider),
                  const SizedBox(height: 20),

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
                  if (provider.tripType == TripType.roundTrip) ...[
                    _buildReturnDateField(provider),
                    const SizedBox(height: 20),
                  ],

                  // Passenger Count
                  _buildPassengerCount(provider),
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

  Widget _buildTripDirectionSelector(HomeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDirectionOption(
              provider,
              TripDirection.fromAirport,
              AppLocalizations.of(context)!.fromAirport,
              Icons.flight_takeoff,
            ),
          ),
          Expanded(
            child: _buildDirectionOption(
              provider,
              TripDirection.toAirport,
              AppLocalizations.of(context)!.toAirport,
              Icons.flight_land,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionOption(
    HomeProvider provider,
    TripDirection direction,
    String label,
    IconData icon,
  ) {
    final isSelected = provider.tripDirection == direction;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        provider.setTripDirection(direction);
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

  Widget _buildTripTypeSelector(HomeProvider provider) {
    return InputContainer(
      label: AppLocalizations.of(context)!.tripType,
      child: DropdownButtonFormField<TripType>(
        value: provider.tripType,
        decoration: InputDecoration(
          hintText: 'Select trip type',
          hintStyle: TextStyle(color: Colors.black, fontSize: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: Colors.transparent,
        ),
        items: [
          DropdownMenuItem<TripType>(
            value: TripType.oneWay,
            child: Row(
              children: [
                Icon(Icons.flight, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.oneWay),
              ],
            ),
          ),
          DropdownMenuItem<TripType>(
            value: TripType.roundTrip,
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.roundTrip),
              ],
            ),
          ),
        ],
        onChanged: (TripType? newValue) {
          if (newValue != null) {
            HapticFeedback.mediumImpact();
            provider.setTripType(newValue);
          }
        },
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
          label:
              provider.tripDirection == TripDirection.fromAirport
                  ? AppLocalizations.of(context)!.pickupAirport
                  : AppLocalizations.of(context)!.pickupLocation,
          hintText:
              provider.tripDirection == TripDirection.fromAirport
                  ? AppLocalizations.of(context)!.selectAirport
                  : AppLocalizations.of(context)!.searchLocation,
          controller: provider.pickupController,
          focusNode: provider.pickupFocus,
          isAirport: provider.tripDirection == TripDirection.fromAirport,
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
          label:
              provider.tripDirection == TripDirection.fromAirport
                  ? AppLocalizations.of(context)!.destinationLocation
                  : AppLocalizations.of(context)!.destinationAirport,
          hintText:
              provider.tripDirection == TripDirection.fromAirport
                  ? AppLocalizations.of(context)!.searchLocation
                  : AppLocalizations.of(context)!.selectAirport,
          controller: provider.destinationController,
          focusNode: provider.destinationFocus,
          isAirport: provider.tripDirection == TripDirection.toAirport,
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
    required bool isAirport,
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

          await NavigationUtils.push<Either<GMLocation, AirportSuggestion>>(
            context,
            LocationPickerScreen(
              title: label,
              hintText: hintText,
              isAirport: isAirport,
              googleMapsApiKey: sharedProvider.setting?.gmApiKey ?? '',
              onSubmit: onLocationSelected,
              selectedAirport:
                  !isAirport
                      ? otherLocation?.fold(
                        (gmLocation) => null,
                        (airport) => airport,
                      )
                      : null,
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
              Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightDateField(HomeProvider provider) {
    return InputContainer(
      label:
          provider.tripDirection == TripDirection.fromAirport
              ? AppLocalizations.of(context)!.flightArrival
              : AppLocalizations.of(context)!.flightDeparture,
      child: InkwellWithOpacity(
        onTap: () async {
          final DateTime? newSelectedDateTime =
              await NavigationUtils.push<DateTime>(
                context,
                DateTimePickerScreen(initialDate: provider.flightDate),
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
                          : '${provider.flightDate!.day}/${provider.flightDate!.month}/${provider.flightDate!.year} ${provider.flightDate!.hour.toString().padLeft(2, '0')}:${provider.flightDate!.minute.toString().padLeft(2, '0')}')
                      : AppLocalizations.of(context)!.selectDateAndTime,
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
    return InputContainer(
      label: AppLocalizations.of(context)!.returnFlight,
      child: InkWell(
        onTap: () async {
          final DateTime? newSelectedDateTime =
              await NavigationUtils.push<DateTime>(
                context,
                DateTimePickerScreen(
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
                          : '${provider.returnFlightDate!.day}/${provider.returnFlightDate!.month}/${provider.returnFlightDate!.year} ${provider.returnFlightDate!.hour.toString().padLeft(2, '0')}:${provider.returnFlightDate!.minute.toString().padLeft(2, '0')}')
                      : AppLocalizations.of(context)!.selectReturnDateAndTime,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerCount(HomeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.passengers,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildPassengerCounter(
            AppLocalizations.of(context)!.adults,
            AppLocalizations.of(context)!.adultsAge,
            provider.adults,
            (count) => provider.setAdults(count),
            Icons.person,
          ),
          const SizedBox(height: 16),
          _buildPassengerCounter(
            AppLocalizations.of(context)!.children,
            AppLocalizations.of(context)!.childrenAge,
            provider.children,
            (count) => provider.setChildren(count),
            Icons.child_care,
          ),
          const SizedBox(height: 16),
          _buildPassengerCounter(
            AppLocalizations.of(context)!.infants,
            AppLocalizations.of(context)!.infantsAge,
            provider.babies,
            (count) => provider.setBabies(count),
            Icons.baby_changing_station,
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerCounter(
    String label,
    String subtitle,
    int count,
    Function(int) onChanged,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.black, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                if (label == 'Adults' && count > 1) {
                  onChanged(count - 1);
                } else if (label != 'Adults' && count > 0) {
                  onChanged(count - 1);
                }
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      (label == 'Adults' && count <= 1) ||
                              (label != 'Adults' && count <= 0)
                          ? Colors.grey[300]
                          : AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.remove,
                  color:
                      (label == 'Adults' && count <= 1) ||
                              (label != 'Adults' && count <= 0)
                          ? Colors.grey[500]
                          : Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onChanged(count + 1);
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
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
