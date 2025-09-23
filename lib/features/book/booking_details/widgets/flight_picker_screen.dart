import 'package:flutter/material.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/custom_cached_image.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/book/booking_details/booking_details_service.dart';
import 'package:welcome_port/features/book/booking_details/models/flight_suggestion.dart';

class FlightPickerScreen extends StatefulWidget {
  final String title;
  final String hintText;
  final Function(FlightSuggestion) onSubmit;

  const FlightPickerScreen({
    super.key,
    required this.title,
    required this.hintText,
    required this.onSubmit,
  });

  @override
  State<FlightPickerScreen> createState() => _FlightPickerScreenState();
}

class _FlightPickerScreenState extends State<FlightPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  final BookingDetailsService service = BookingDetailsService();

  List<FlightSuggestion> _flightSuggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _searchFlightNumbers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _flightSuggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await service.autocompleteFlightNumber(query);

    result.fold(
      (error) {
        setState(() {
          _isLoading = false;
          _flightSuggestions = [];
        });
      },
      (suggestions) {
        setState(() {
          _isLoading = false;
          _flightSuggestions = suggestions;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    decoration: InputDecoration(
                      hintText: "Type your flight number",
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _searchFlightNumbers(value);
                    },
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildSearchResults(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    // Hide content when text field is empty
    if (_searchController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return Loader(color: Colors.black);
    }

    if (_flightSuggestions.isEmpty) {
      return const Center(
        child: Text(
          'No flights found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SEARCH RESULTS",
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children:
              _flightSuggestions
                  .map((suggestion) => _buildFlightSuggestionItem(suggestion))
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildFlightSuggestionItem(FlightSuggestion suggestion) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      // leading: const Icon(Icons.flight, color: AppColors.primaryColor),
      leading: SizedBox(
        width: 60,
        height: 32,
        child: CustomCachedImage(imageUrl: suggestion.airlineLogo),
      ),
      title: Text(
        suggestion.flightNumber,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        suggestion.airlineCode,
        style: TextStyle(color: Colors.grey[600]),
      ),
      onTap: () {
        widget.onSubmit(suggestion);
        Navigator.pop(context);
      },
    );
  }
}
