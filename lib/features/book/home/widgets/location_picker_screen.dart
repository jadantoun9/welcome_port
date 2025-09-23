import 'dart:async';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/book/home/home_service.dart';
import 'package:welcome_port/features/book/home/models/airport_suggestion.dart';
import 'package:welcome_port/features/book/home/models/gm_location.dart';
import 'package:welcome_port/features/book/home/models/google_suggested_location.dart';
import 'package:welcome_port/features/book/home/utils/google_map_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocationPickerScreen extends StatefulWidget {
  final String title;
  final String hintText;
  final bool isAirport;
  final String googleMapsApiKey;
  final AirportSuggestion? selectedAirport;
  final Function(Either<GMLocation, AirportSuggestion>)? onSubmit;

  const LocationPickerScreen({
    super.key,
    required this.title,
    required this.hintText,
    required this.isAirport,
    required this.googleMapsApiKey,
    required this.selectedAirport,
    this.onSubmit,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final HomeService _homeService = HomeService();

  List<AirportSuggestion> _airportSuggestions = [];
  List<GoogleSuggestedLocation> _googleSuggestions = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

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
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _airportSuggestions = [];
        _googleSuggestions = [];
        _isLoading = false;
      });
      return;
    }

    // Set loading state immediately
    setState(() {
      _isLoading = true;
    });

    // Start new timer for debounced search
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      if (widget.isAirport) {
        _searchAirports(query);
      } else {
        _searchGoogleMaps(query);
      }
    });
  }

  Future<void> _searchAirports(String query) async {
    if (query.isEmpty) {
      setState(() {
        _airportSuggestions = [];
        _isLoading = false;
      });
      return;
    }

    final result = await _homeService.getAirportSuggestions(query);

    result.fold(
      (error) {
        setState(() {
          _isLoading = false;
          _airportSuggestions = [];
        });
      },
      (suggestions) {
        setState(() {
          _isLoading = false;
          _airportSuggestions = suggestions;
        });
      },
    );
  }

  Future<void> _searchGoogleMaps(String query) async {
    if (query.isEmpty) {
      setState(() {
        _googleSuggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final suggestions = await GoogleMapUtils.getSuggestionsForKeyword(
      query,
      widget.googleMapsApiKey,
    );

    setState(() {
      _isLoading = false;
      _googleSuggestions = suggestions ?? [];
    });
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
                      hintText: AppLocalizations.of(context)!.typeCityOrAirport,
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
                      _onSearchChanged(value);
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
                      const SizedBox(height: 16),
                      _buildLocationSuggestions(),
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

    if (widget.isAirport) {
      if (_airportSuggestions.isEmpty) {
        return Center(
          child: Text(
            AppLocalizations.of(context)!.noAirportsFound,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.searchResults,
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
                _airportSuggestions
                    .map(
                      (suggestion) => _buildAirportSuggestionItem(suggestion),
                    )
                    .toList(),
          ),
        ],
      );
    } else {
      if (_googleSuggestions.isEmpty) {
        return Center(
          child: Text(
            AppLocalizations.of(context)!.noLocationsFound,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.searchResults,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            children:
                _googleSuggestions
                    .map(
                      (suggestion) =>
                          _buildGoogleMapsSuggestionItem(suggestion),
                    )
                    .toList(),
          ),
        ],
      );
    }
  }

  Widget _buildAirportSuggestionItem(AirportSuggestion suggestion) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.flight, color: AppColors.primaryColor),
      title: Text(
        suggestion.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        suggestion.code,
        style: TextStyle(color: Colors.grey[600]),
      ),
      onTap: () {
        if (widget.onSubmit != null) {
          widget.onSubmit!(Right(suggestion));
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildGoogleMapsSuggestionItem(GoogleSuggestedLocation suggestion) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4),
      leading: const Icon(Icons.location_on, color: AppColors.primaryColor),
      title: Text(
        suggestion.mainText,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle:
          suggestion.secondaryText.isNotEmpty
              ? Text(
                suggestion.secondaryText,
                style: TextStyle(color: Colors.grey[600]),
              )
              : null,
      onTap: () async {
        if (widget.onSubmit != null) {
          // Get the LatLng for this location
          final latLng = await GoogleMapUtils.getPlaceDetails(
            suggestion.placeId,
            widget.googleMapsApiKey,
          );

          if (latLng != null) {
            final gmLocation = GMLocation(
              latLng: latLng,
              mainText: suggestion.mainText,
              secondaryText: suggestion.secondaryText,
              description: suggestion.description,
            );
            widget.onSubmit!(Left(gmLocation));
            Navigator.pop(context);
          }
        }
      },
    );
  }

  Widget _buildLocationSuggestions() {
    if (widget.selectedAirport?.locations.isNotEmpty ?? false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.popularLocations,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children:
                widget.selectedAirport?.locations
                    .map(
                      (location) => InkwellWithOpacity(
                        onTap: () async {
                          if (widget.onSubmit != null) {
                            final gmLocation = GMLocation(
                              latLng: LatLng(
                                location.latitude,
                                location.longitude,
                              ),
                              mainText: location.name,
                              secondaryText: '',
                              description: '',
                            );
                            widget.onSubmit!(Left(gmLocation));
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            location.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList() ??
                [],
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
