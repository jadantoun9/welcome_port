import 'package:welcome_port/core/models/quote.dart';

class GetQuotesResponse {
  final List<Quote> quotes;
  final int expirationTime;

  GetQuotesResponse({required this.quotes, required this.expirationTime});

  factory GetQuotesResponse.fromJson(Map<String, dynamic> json) {
    return GetQuotesResponse(
      quotes:
          (json['quotes'] as List<dynamic>)
              .map((quote) => Quote.fromJson(quote))
              .toList(),
      expirationTime: int.tryParse(json['expiration_duration'].toString()) ?? 0,
    );
  }
}
