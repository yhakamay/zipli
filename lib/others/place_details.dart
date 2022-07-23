import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDetails {
  PlaceDetails({
    required this.name,
    required this.rating,
    required this.formattedAddress,
    required this.city,
    required this.location,
  });

  final String? name;
  final String? formattedAddress;
  final double? rating;
  final String? city;
  final LatLng? location;

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'formattedAddress': formattedAddress,
      'rating': rating,
      'city': city,
      'location': location?.toJson(),
    };
  }

  factory PlaceDetails.fromFirestore(Map<String, dynamic> firestore) {
    return PlaceDetails(
      name: firestore['name'],
      formattedAddress: firestore['formattedAddress'],
      rating: firestore['rating'],
      city: firestore['city'],
      location: firestore['location'] != null
          ? LatLng.fromJson(firestore['location'])
          : null,
    );
  }
}
