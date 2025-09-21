import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/features/book/booking_details/booking_details_provider.dart';
import 'package:welcome_port/features/book/booking_details/widgets/continue_button.dart';
import 'package:welcome_port/features/book/booking_details/widgets/customer_info_card.dart';
import 'package:welcome_port/features/book/booking_details/widgets/children_age_card.dart';
import 'package:welcome_port/features/book/booking_details/widgets/departure_information_card.dart';
import 'package:welcome_port/features/book/quotes/models/prebook_requirements_response.dart';

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

class _BookingDetailsContent extends StatelessWidget {
  const _BookingDetailsContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingDetailsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                // Custom back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF666666),
                      size: 22,
                    ),
                  ),
                ),
                const Spacer(),
                // Title
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                // Placeholder for symmetry
                const SizedBox(width: 44),
              ],
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: provider.formKey,
                  child: Column(
                    children: [
                      CustomerInfoCard(provider: provider),
                      const SizedBox(height: 24),
                      ChildrenAgeCard(provider: provider),
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
                      ContinueButton(provider: provider),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
