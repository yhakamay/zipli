import 'dart:convert';

import 'package:http/http.dart';

import 'place_details.dart';
import 'place_suggestion.dart';

class PlaceAPI {
  final _client = Client();
  final String sessionToken;
  final _apiKey = 'AIzaSyDMBUCe1rbRT_oEvZ9VC9MQTGoHEKt-lN4';
  final _placeApiBaseUrl = 'https://maps.googleapis.com/maps/api/place';

  PlaceAPI({required this.sessionToken});

  Future<List<PlaceSuggestion>> fetchSuggestions(
      String input, String lang) async {
    final request = Uri.parse(
        '$_placeApiBaseUrl/autocomplete/json?input=$input&types=establishment&language=$lang&key=$_apiKey&sessiontoken=$sessionToken');
    final response = await _client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<PlaceSuggestion>(
                (p) => PlaceSuggestion(p['place_id'], p['description']))
            .toList();
      }

      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }

      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    final request = Uri.parse(
        '$_placeApiBaseUrl/details/json?fields=name%2Crating%2Cformatted_address%2Caddress_components&place_id=$placeId&key=$_apiKey&sessiontoken=$sessionToken');
    final response = await _client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      if (result['status'] == 'OK') {
        final components =
            result['result']['address_components'] as List<dynamic>;
        String? city;

        for (dynamic component in components) {
          final List type = component['types'];
          if (type.contains('locality')) {
            city = component['long_name'];
          }
        }

        return PlaceDetails(
          name: result['result']['name'],
          city: city,
          rating: result['result']['rating'].toDouble(),
          formattedAddress: result['result']['formatted_address'],
        );
      }

      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to get place details');
    }
  }
}
