import 'package:welcome_port/features/book/home/models/airport_suggestion.dart';
import 'package:welcome_port/features/book/home/models/google_suggested_location.dart';

final List<AirportSuggestion> initialAirportSuggestions = [
  AirportSuggestion(
    id: 1650,
    name: 'Dubai International Airport',
    code: 'DXB',
    country: 'United Arab Emirates',
    countryCode: 'AE',
    locations: [
      LocationSuggestion(
        name: 'Abu Dhabi airport',
        latitude: 24.434804,
        longitude: 54.650288,
      ),
      LocationSuggestion(
        name: 'Abu Dhabi city (all areas)',
        latitude: 24.466838,
        longitude: 54.366503,
      ),
      LocationSuggestion(
        name: 'Abu Dhabi cruise terminal',
        latitude: 24.529014,
        longitude: 54.380296,
      ),
      LocationSuggestion(
        name: 'Ajman',
        latitude: 25.403197,
        longitude: 55.491843,
      ),
      LocationSuggestion(
        name: 'Al Ain',
        latitude: 24.206263,
        longitude: 55.743828,
      ),
    ],
  ),
  AirportSuggestion(
    id: 6887,
    name: 'Istanbul Airport',
    code: 'IST',
    country: 'Turkey',
    countryCode: 'TR',
    locations: [
      LocationSuggestion(
        name: 'Abant',
        latitude: 40.606419,
        longitude: 31.279306,
      ),
      LocationSuggestion(
        name: 'Adapazari',
        latitude: 40.788922,
        longitude: 30.405893,
      ),
      LocationSuggestion(
        name: 'Aksaray (Istanbul)',
        latitude: 41.009633,
        longitude: 28.953577,
      ),
      LocationSuggestion(
        name: 'Altimermer',
        latitude: 41.007925,
        longitude: 28.931251,
      ),
      LocationSuggestion(
        name: 'Atakoy',
        latitude: 40.978094,
        longitude: 28.868408,
      ),
    ],
  ),
];

final List<GoogleSuggestedLocation> initialLocationSuggestions = [
  GoogleSuggestedLocation(
    mainText: 'Eiffel Tower',
    secondaryText:
        'Sheikh Mohammed bin Rashid Boulevard - Dubai - United Arab Emirates',
    description:
        'Burj Khalifa - Sheikh Mohammed bin Rashid Boulevard - Dubai - United Arab Emirates',
    placeId: 'ChIJLU7jZClu5kcR4PcOOO6p3I0',
    types: ["establishment", "point_of_interest", "tourist_attraction"],
  ),
  GoogleSuggestedLocation(
    mainText: 'Burj Khalifa',
    secondaryText: 'Dubai, United Arab Emirates',
    description: 'Burj Khalifa, Dubai, United Arab Emirates',
    placeId: 'ChIJS-JnijRDXz4R4rfO4QLlRf8',
    types: [
      "establishment",
      "landmark",
      "point_of_interest",
      "tourist_attraction",
    ],
  ),
  GoogleSuggestedLocation(
    mainText: 'Taksim Square',
    secondaryText: 'Kocatepe, Beyoğlu/İstanbul, Türkiye',
    description: 'Taksim Square, Kocatepe, Beyoğlu/İstanbul, Türkiye',
    placeId: 'ChIJY71WBmW3yhQRw7YgjLJYoIw',
    types: ["geocode", "neighborhood", "political"],
  ),
];
