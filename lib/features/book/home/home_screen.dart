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
                    'Book Transfer',
                    style: TextStyle(
                      color: Colors.grey[100],
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Quick and easy airport transfers',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
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
                    text: 'Search Booking',
                    onPressed: () => provider.handleSearch(context, provider),
                    isLoading: provider.isLoading,
                    bgColor: Colors.amber,
                  ),
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
              'From Airport',
              Icons.flight_takeoff,
            ),
          ),
          Expanded(
            child: _buildDirectionOption(
              provider,
              TripDirection.toAirport,
              'To Airport',
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
      label: 'Trip Type',
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
                const Text('One Way'),
              ],
            ),
          ),
          DropdownMenuItem<TripType>(
            value: TripType.roundTrip,
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                const Text('Round Trip'),
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
                  ? 'Pickup Airport'
                  : 'Pick Up Location',
          hintText:
              provider.tripDirection == TripDirection.fromAirport
                  ? 'Select Airport'
                  : 'Search Location',
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
                  ? 'Destination Location'
                  : 'Destination Airport',
          hintText:
              provider.tripDirection == TripDirection.fromAirport
                  ? 'Search Location'
                  : 'Select Airport',
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
              ? 'Flight Arrival'
              : 'Flight Departure',
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
                      : 'Select Date & Time',
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
      label: 'Return Flight',
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
                      : 'Select Return Date & Time',
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
            'Passengers',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildPassengerCounter(
            'Adults',
            '(16+ years)',
            provider.adults,
            (count) => provider.setAdults(count),
            Icons.person,
          ),
          const SizedBox(height: 16),
          _buildPassengerCounter(
            'Children',
            '(2-15 years)',
            provider.children,
            (count) => provider.setChildren(count),
            Icons.child_care,
          ),
          const SizedBox(height: 16),
          _buildPassengerCounter(
            'Infants',
            '(0-2 years)',
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
}
